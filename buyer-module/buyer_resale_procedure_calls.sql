-- Write your procedure calls here

-- HOW TO RUN: This is step 9 of the full sequence, run on a FRESH
-- database, AFTER all 8 definition files below have already been loaded
-- in order:
--   1. schema/schema.sql
--   2. schema/data_validation_triggers.sql
--   3. organization-module/organization_procedures.sql
--   4. organization-module/organization_functions.sql
--   5. organizer-module/organizer_procedures.sql
--   6. organizer-module/organizer_functions.sql
--   7. buyer-module/buyer_resale_procedures.sql
--   8. buyer-module/buyer_resale_functions.sql
--   9. buyer-module/buyer_resale_procedure_calls.sql   <-- THIS FILE
--  10. buyer-module/buyer_resale_function_calls.sql
--
-- IMPORTANT: Run this on a database that has NOT already had
-- organization_procedure_calls.sql / organization_function_calls.sql
-- (the org module's own demo files) run in it. This file creates its
-- own sample organization #1, venue #1, event #1 etc. from scratch, so
-- if another module's demo data has already used those same IDs/emails,
-- some INSERT statements below will fail with duplicate-key errors. That
-- is a demo-data collision between two independent scripts, not a
-- correctness issue with the procedures.
--
-- EXPECTED OUTPUT:
--   - Section 1: setup NOTICEs from create_event/create_concert/
--     publish_event/approve_organizer/schedule_event, then a SELECT
--     showing ticket 1 as 'Sold', and 3 sample buyers inserted.
--   - Section 2 (List Ticket For Resale): NOTICE "Ticket listed for
--     resale successfully." then a SELECT showing 1 row with
--     status = 'Listed'. Section 2.1 is an INTENTIONAL error
--     ("...exceeds the maximum permitted resale profit margin...") -
--     this demonstrates the price-cap validation working correctly.
--   - Section 3 (Purchase Resale Ticket): NOTICE "Ticket purchased
--     successfully via resale.", ownership transferred to buyer 2,
--     resale_payment row showing a 10% organization commission split.
--     Sections 3.1 and 3.2 are INTENTIONAL errors ("...not listed for
--     resale." and "...cannot purchase your own listed ticket.").
--   - Section 4 (Withdraw Resale Listing): NOTICE "Resale listing
--     withdrawn successfully.", listing status becomes 'Withdrawn'.
--     Section 4.1 is an INTENTIONAL error ("Only active listings can be
--     withdrawn.").
--   - Section 5 (Submit Buyer Review): NOTICE "Review submitted
--     successfully.". Section 5.1 is an INTENTIONAL error ("...already
--     submitted a review...").
--   - Section 6 (Update Buyer Review): NOTICE "Review updated
--     successfully.". Section 6.1 is an INTENTIONAL error ("No review
--     exists for this event.").
--
-- In total, 6 ERROR lines are expected in this file's output, and every
-- one of them is a deliberate validation demonstration, not a bug.
-- ============================================================================

-- 1.1. Sample setup data (organization, venue, seats, event, organizer)
-- Required so that tickets exist for the resale demonstration below.

INSERT INTO organization (
    name, email, phone, password, url, owner, registration_no, address
)
VALUES (
    'Tech Events', 'info@techevents.com', '0300-1234567', 'Password123',
    'https://techevents.com', 'Ali Khan', '1234567', 'Lahore, Pakistan'
);

INSERT INTO venue (name, city, country, capacity, type, address)
VALUES ('Small Arena', 'Karachi', 'Pakistan', 3, 'Stadium', 'Karachi, Pakistan');

INSERT INTO seat (row, number, section, seat_type, venue_id)
VALUES
    ('A', 1, 'Front', 'Regular', 1),
    ('A', 2, 'Front', 'Premium', 1),
    ('A', 3, 'Front', 'VIP', 1);

CALL create_event(
    p_title := 'Coke Studio Live',
    p_description := 'Live concert for the resale module demonstration.',
    p_start_datetime := '2026-08-10 15:00:00',
    p_end_datetime := '2026-08-10 22:00:00',
    p_sale_start_datetime := '2026-07-20 00:00:00',
    p_sale_end_datetime := '2026-08-09 23:59:59',
    p_offered_payment := 5000.00,
    p_reservation_expiry_duration := 15,
    p_is_resale_allowed := TRUE,
    p_org_commission_percentage := 10.00,
    p_resale_profit_percentage := 20.00,
    p_max_reservations := 3,
    p_max_bookings := 3,
    p_min_age := NULL,
    p_base_price := 1000.00,
    p_increment_per_seat_type := 200.00,
    p_budget := 50000.00,
    p_organization_id := 1,
    p_venue_id := 1
);

CALL create_concert(p_event_id := 1);

INSERT INTO organizer (name, email, national_id, password, dob, phone)
VALUES ('Ahmed Raza', 'ahmed.raza@email.com', '23456-2345678-2', 'AhmedPass456', '1997-09-21', '0302-2345678');

CALL publish_event(p_event_id := 1);

INSERT INTO application_history (user_id, event_id, applied_at, status)
VALUES (1, 1, DEFAULT, 'Pending');

CALL approve_organizer(p_user_id := 1, p_event_id := 1);

CALL schedule_event(p_event_id := 1);

SELECT ticket_id, price, status, event_id, seat_id FROM ticket;

-- Fast-forward the event to Completed so reviews can be demonstrated later.
UPDATE event SET status = 'Active' WHERE event_id = 1;
UPDATE event SET status = 'Completed' WHERE event_id = 1;

-- 1.2. Sample buyers

INSERT INTO buyer (name, email, national_id, password, dob, phone)
VALUES
    ('Sara Ahmed', 'sara.ahmed@example.com', '35202-1111111-1', 'SaraPass1', '1999-01-15', '0311-1111111'),
    ('Bilal Khan', 'bilal.khan@example.com', '35202-2222222-2', 'BilalPass2', '1998-06-20', '0312-2222222'),
    ('Zainab Ali', 'zainab.ali@example.com', '35202-3333333-3', 'ZainabPass3', '2000-03-05', '0313-3333333');

-- 1.3. Simulate that ticket 1 was already booked and is owned by Sara (buyer 1).

INSERT INTO transaction (amount, payment_method, payment_status)
VALUES (1000.00, 'Card', 'Completed');

INSERT INTO initial_payment (transaction_id, organization_id, user_id, ticket_id)
VALUES (1, 1, 1, 1);

UPDATE ticket SET status = 'Sold' WHERE ticket_id = 1;

INSERT INTO ownership_history (user_id, ticket_id, is_current)
VALUES (1, 1, TRUE);

-- 2. List Ticket For Resale
-- Sara lists ticket 1 for resale. Base price is 1000, resale_profit_percentage
-- is 20%, so the maximum allowed listing price is 1200.

CALL list_ticket_for_resale(
    p_user_id := 1,
    p_ticket_id := 1,
    p_listed_price := 1150.00
);

SELECT * FROM resale_listing_history;

-- 2.1. Validation demonstration: listing above the allowed profit margin fails.

CALL list_ticket_for_resale(
    p_user_id := 1,
    p_ticket_id := 1,
    p_listed_price := 5000.00
);

-- 3. Purchase Resale Ticket
-- Bilal (buyer 2) purchases the ticket Sara listed for resale.

CALL purchase_resale_ticket(
    p_buyer_id := 2,
    p_ticket_id := 1,
    p_payment_method := 'JazzCash'
);

SELECT * FROM ownership_history WHERE ticket_id = 1;
SELECT * FROM resale_listing_history WHERE ticket_id = 1;
SELECT * FROM resale_payment;

-- 3.1. Validation demonstration: purchasing a ticket that is not listed fails.

CALL purchase_resale_ticket(
    p_buyer_id := 3,
    p_ticket_id := 2,
    p_payment_method := 'Card'
);

-- 3.2. Validation demonstration: a buyer cannot purchase their own listing.

CALL list_ticket_for_resale(
    p_user_id := 2,
    p_ticket_id := 1,
    p_listed_price := 1000.00
);

CALL purchase_resale_ticket(
    p_buyer_id := 2,
    p_ticket_id := 1,
    p_payment_method := 'Card'
);

-- 4. Withdraw Resale Listing
-- Bilal, now the current owner, withdraws his own active listing.

SELECT * FROM resale_listing_history WHERE ticket_id = 1;

CALL withdraw_resale_listing(
    p_user_id := 2,
    p_ticket_id := 1
);

SELECT * FROM resale_listing_history WHERE ticket_id = 1;

-- 4.1. Validation demonstration: withdrawing an already-withdrawn listing fails.

CALL withdraw_resale_listing(
    p_user_id := 2,
    p_ticket_id := 1
);

-- 5. Submit Buyer Review
-- Bilal reviews the event, since he currently owns a ticket for it and the
-- event has been marked Completed.

CALL submit_buyer_review(
    p_user_id := 2,
    p_event_id := 1,
    p_rating := 5,
    p_comment := 'Amazing concert experience!'
);

SELECT * FROM buyer_review;

-- 5.1. Validation demonstration: a second review for the same event fails.

CALL submit_buyer_review(
    p_user_id := 2,
    p_event_id := 1,
    p_rating := 4,
    p_comment := 'Trying to submit again'
);

-- 6. Update Buyer Review

CALL update_buyer_review(
    p_user_id := 2,
    p_event_id := 1,
    p_rating := 4,
    p_comment := 'Updating my thoughts after some reflection.'
);

SELECT * FROM buyer_review;

-- 6.1. Validation demonstration: updating a review that does not exist fails.

CALL update_buyer_review(
    p_user_id := 3,
    p_event_id := 1,
    p_rating := 3
);