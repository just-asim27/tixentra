-- 1. Organization Registrations 

CALL register_organization(
    p_name := 'Tech Events',
    p_email := 'info@techevents.com',
    p_phone := '0300-1234567',
    p_password := 'Password123',
    p_url := 'https://techevents.com',
    p_owner := 'Ali Khan',
    p_registration_no := '1234567',
    p_address := 'Lahore, Pakistan'
);

CALL register_organization(
    p_name := 'Prime Productions',
    p_email := 'contact@primeproductions.pk',
    p_phone := '0301-2345678',
    p_password := 'PrimePass456',
    p_url := 'https://primeproductions.pk',
    p_owner := 'Ahmed Raza',
    p_registration_no := '2345678',
    p_address := 'Islamabad, Pakistan'
);

CALL register_organization(
    p_name := 'Elite Entertainment',
    p_email := 'support@eliteentertainment.com',
    p_phone := '0302-3456789',
    p_password := 'Elite789',
    p_url := 'https://eliteentertainment.com',
    p_owner := 'Fatima Noor',
    p_registration_no := '3456789',
    p_address := 'Karachi, Pakistan'
);

CALL register_organization(
    p_name := 'Vision Events',
    p_email := 'hello@visionevents.pk',
    p_phone := '0303-4567890',
    p_password := 'Vision2026',
    p_url := NULL,
    p_owner := 'Usman Tariq',
    p_registration_no := '4567890',
    p_address := 'Faisalabad, Pakistan'
);

CALL register_organization(
    p_name := 'NextGen Conferences',
    p_email := 'admin@nextgenconf.org',
    p_phone := '0304-5678901',
    p_password := 'NextGen321',
    p_url := 'https://nextgenconf.org',
    p_owner := 'Sarah Khan',
    p_registration_no := '5678901',
    p_address := 'Rawalpindi, Pakistan'
);

SELECT * FROM organization;

-- 2.1. Required venue data for event creation calls

INSERT INTO venue (
    name,
    city,
    country,
    capacity,
    type,
    address
)
VALUES
(
    'National Stadium',
    'Karachi',
    'Pakistan',
    30,
    'Stadium',
    'Karachi, Pakistan'
),

(
    'Gaddafi Stadium',
    'Lahore',
    'Pakistan',
    60,
    'Stadium',
    'Lahore, Pakistan'
);

-- 2.2. Event Creations

CALL create_event(
    p_title := 'Pakistan vs India ODI',
    p_description := 'Asia Cup 2026 group stage match.',
    p_start_datetime := (CURRENT_TIMESTAMP + INTERVAL '2 hours')::timestamp,
    p_end_datetime := (CURRENT_TIMESTAMP + INTERVAL '9 hours')::timestamp,
    p_sale_start_datetime := (CURRENT_TIMESTAMP - INTERVAL '30 days')::timestamp,
    p_sale_end_datetime := (CURRENT_TIMESTAMP + INTERVAL '1 hour')::timestamp,
    p_offered_payment := 50000.00,
    p_reservation_expiry_duration := 15,
    p_is_resale_allowed := TRUE,
    p_org_commission_percentage := 10.00,
    p_resale_profit_percentage := 5.00,
    p_max_reservations := 5,
    p_max_bookings := 4,
    p_min_age := NULL,
    p_base_price := 1500.00,
    p_increment_per_seat_type := 200.00,
    p_budget := 800000.00,
    p_is_refund_allowed := TRUE,
    p_organization_id := 1,
    p_venue_id := 1
);

CALL create_event(
    p_title := 'England vs Australia T20',
    p_description := 'International T20 series match.',
    p_start_datetime := (CURRENT_TIMESTAMP + INTERVAL '3 hours')::timestamp,
    p_end_datetime := (CURRENT_TIMESTAMP + INTERVAL '7 hours 30 minutes')::timestamp,
    p_sale_start_datetime := (CURRENT_TIMESTAMP + INTERVAL '1 hour')::timestamp,
    p_sale_end_datetime := (CURRENT_TIMESTAMP + INTERVAL '90 minutes')::timestamp,
    p_offered_payment := 75000.00,
    p_reservation_expiry_duration := 10,
    p_is_resale_allowed := FALSE,
    p_org_commission_percentage := 0.00,
    p_resale_profit_percentage := 0.00,
    p_max_reservations := 8,
    p_max_bookings := 6,
    p_min_age := NULL,
    p_base_price := 2000.00,
    p_increment_per_seat_type := 500.00,
    p_budget := 1500000.00,
    p_is_refund_allowed := FALSE,
    p_organization_id := 2,
    p_venue_id := 2
);

-- 2.3. Create Sports Details

CALL create_sports(
    p_event_id := 1,
    p_sport_type := 'Cricket',
    p_home_team := 'Pakistan',
    p_away_team := 'India',
    p_competition_name := 'Asia Cup 2026'
);

CALL create_sports(
    p_event_id := 2,
    p_sport_type := 'Cricket',
    p_home_team := 'England',
    p_away_team := 'Australia',
    p_competition_name := 'World T20 Series'
);

SELECT * FROM event;
SELECT * FROM sports;

-- 3. Update Event

CALL update_event(
    p_event_id := 1,
    p_title := 'Pakistan vs India ODI - Updated',
    p_description := 'Asia Cup 2026 group stage match with updated event information.',
    p_offered_payment := 60000.00,
    p_max_reservations := 6,
    p_max_bookings := 5,
    p_base_price := 1800.00,
    p_budget := 900000.00
);

CALL update_sports(
    p_event_id := 1,
    p_competition_name := 'Asia Cup 2026 - Final'
);

SELECT * FROM event WHERE event_id = 1;
SELECT * FROM sports WHERE event_id = 1;

-- 4. Publish Event

CALL publish_event(
    p_event_id := 1
);

SELECT * FROM event WHERE event_id = 1;

-- 5. Organizer Registrations

CALL register_organizer(
    p_name := 'Ali Hassan',
    p_email := 'ali.hassan@email.com',
    p_national_id := '12345-1234567-1',
    p_password := 'AliPass123',
    p_dob := '1998-05-14',
    p_phone := '0301-1234567'
);

CALL register_organizer(
    p_name := 'Ahmed Raza',
    p_email := 'ahmed.raza@email.com',
    p_national_id := '23456-2345678-2',
    p_password := 'AhmedPass456',
    p_dob := '1997-09-21',
    p_phone := '0302-2345678'
);

CALL register_organizer(
    p_name := 'Fatima Noor',
    p_email := 'fatima.noor@email.com',
    p_national_id := '34567-3456789-3',
    p_password := 'FatimaPass789',
    p_dob := '1999-02-10',
    p_phone := '0303-3456789'
);

SELECT * FROM organizer;

-- 6. Browse Events Open for Applications

SELECT * FROM get_open_events();

-- 7. Apply to Event

CALL apply_to_event(
    p_user_id := 1,
    p_event_id := 1
);

CALL apply_to_event(
    p_user_id := 2,
    p_event_id := 1
);

CALL apply_to_event(
    p_user_id := 3,
    p_event_id := 1
);

SELECT * FROM application_history;

-- 8.1. Historical event data

INSERT INTO event (
    title,
    description,
    start_datetime,
    end_datetime,
    sale_start_datetime,
    sale_end_datetime,
    offered_payment,
    status,
    reservation_expiry_duration,
    is_resale_allowed,
    org_commission_percentage,
    resale_profit_percentage,
    max_reservations,
    max_bookings,
    min_age,
    base_price,
    increment_per_seat_type,
    budget,
    is_refund_allowed,
    organization_id,
    venue_id,
    user_id
)
VALUES

(
    'Pakistan vs India ODI 2025',
    'Asia Cup 2025 group stage cricket match.',
    '2025-03-15 15:00:00',
    '2025-03-15 22:00:00',
    '2025-02-01 00:00:00',
    '2025-03-14 23:59:59',
    45000.00,
    'Completed',
    15,
    TRUE,
    10.00,
    5.00,
    5,
    4,
    NULL,
    1500.00,
    200.00,
    700000.00,
    TRUE,
    1,
    1,
    1
),

(
    'England vs Australia T20 2025',
    'International T20 series cricket match.',
    '2025-05-20 18:00:00',
    '2025-05-20 22:30:00',
    '2025-04-01 00:00:00',
    '2025-05-19 23:59:59',
    70000.00,
    'Completed',
    10,
    FALSE,
    0.00,
    0.00,
    8,
    6,
    NULL,
    2000.00,
    500.00,
    1200000.00,
    FALSE,
    2,
    2,
    2
),

(
    'South Africa vs New Zealand ODI 2025',
    'Champions Trophy 2025 one-day international match.',
    '2025-08-10 14:00:00',
    '2025-08-10 21:00:00',
    '2025-06-15 00:00:00',
    '2025-08-09 23:59:59',
    35000.00,
    'Completed',
    20,
    TRUE,
    8.00,
    3.00,
    6,
    5,
    NULL,
    1800.00,
    250.00,
    900000.00,
    TRUE,
    3,
    1,
    3
),

(
    'Pakistan Super League Final 2025',
    'Historic PSL final successfully managed.',
    '2025-10-05 18:00:00',
    '2025-10-05 22:30:00',
    '2025-08-20 00:00:00',
    '2025-10-04 23:59:59',
    60000.00,
    'Completed',
    15,
    TRUE,
    10.00,
    5.00,
    5,
    4,
    NULL,
    1700.00,
    300.00,
    950000.00,
    TRUE,
    1,
    2,
    2
),

(
    'Champions Trophy Final 2025',
    'International championship final.',
    '2025-12-12 17:00:00',
    '2025-12-12 22:00:00',
    '2025-10-20 00:00:00',
    '2025-12-11 23:59:59',
    65000.00,
    'Completed',
    15,
    TRUE,
    8.00,
    4.00,
    6,
    5,
    NULL,
    2200.00,
    400.00,
    1100000.00,
    FALSE,
    2,
    1,
    1
);

INSERT INTO sports (
    event_id,
    sport_type,
    home_team,
    away_team,
    competition_name
)
VALUES

(3,'Cricket','Pakistan','India','Asia Cup 2025'),

(4,'Cricket','England','Australia','World T20 Series'),

(5,'Cricket','South Africa','New Zealand','Champions Trophy'),

(6,'Cricket','Lahore Qalandars','Karachi Kings','Pakistan Super League'),

(7,'Cricket','India','Australia','ICC Champions Trophy');

-- 8.2. Sample Organization Reviews

INSERT INTO organization_review (
    rating,
    comment,
    user_id,
    event_id,
    organization_id
)
VALUES

(
    5,
    'Outstanding planning and execution throughout the event.',
    1,
    3,
    1
),

(
    3,
    'The event was completed successfully but communication could be improved.',
    2,
    4,
    2
),

(
    5,
    'Excellent coordination with all stakeholders.',
    3,
    5,
    3
),

(
    4,
    'Reliable organizer with good operational management.',
    2,
    6,
    1
),

(
    5,
    'Handled the event exceptionally well despite operational challenges.',
    1,
    7,
    2
);

-- 8.3. Register Buyers

CALL register_buyer(
    p_name := 'Ahmad Ali',
    p_email := 'ahmad.ali@email.com',
    p_national_id := '35202-1234567-1',
    p_password := 'Ahmad123',
    p_dob := '2000-05-10',
    p_phone := '0300-1234567'
);

CALL register_buyer(
    p_name := 'Sara Khan',
    p_email := 'sara.khan@email.com',
    p_national_id := '35202-2345678-2',
    p_password := 'Sara456',
    p_dob := '1998-08-15',
    p_phone := '0301-2345678'
);

CALL register_buyer(
    p_name := 'Usman Tariq',
    p_email := 'usman.tariq@email.com',
    p_national_id := '35202-3456789-3',
    p_password := 'Usman789',
    p_dob := '2001-03-20',
    p_phone := '0302-3456789'
);

-- 8.4. Sample Buyer Reviews

INSERT INTO buyer_review (
    rating,
    comment,
    user_id,
    event_id
)
VALUES

(
    5,
    'Excellent experience from entry to exit.',
    1,
    3
),
(
    5,
    'Everything was professionally managed.',
    2,
    3
),
(
    4,
    'Very enjoyable event with only minor delays.',
    3,
    3
),

(
    3,
    'Average experience overall.',
    1,
    4
),
(
    4,
    'Good organization but parking needed improvement.',
    2,
    4
),
(
    3,
    'Long waiting time at the entrance.',
    3,
    4
),

(
    5,
    'Outstanding event organization.',
    1,
    5
),
(
    5,
    'One of the best sporting events I have attended.',
    2,
    5
),
(
    5,
    'Excellent crowd management and facilities.',
    3,
    5
),

(
    4,
    'Smooth entry and helpful staff.',
    1,
    6
),
(
    4,
    'Well organized from start to finish.',
    2,
    6
),
(
    5,
    'Fantastic atmosphere and management.',
    3,
    6
),

(
    5,
    'Excellent logistics and seating arrangements.',
    1,
    7
),
(
    4,
    'Very enjoyable experience.',
    2,
    7
),
(
    5,
    'Everything exceeded expectations.',
    3,
    7
);

-- 8.5. Get Event Applications

SELECT *
FROM get_event_applications(1);

-- 9. Approve Organizer

CALL approve_organizer(
    p_user_id := 2,
    p_event_id := 1
);

SELECT * FROM event WHERE event_id = 1;

-- 10. View Application Status

SELECT * FROM get_organizer_applications(1);
SELECT * FROM get_organizer_applications(2);

-- 11.1. Seat Data Required for Schedule Event

DO $$
DECLARE
    v_row INT;
    v_seat INT;

    v_row_letter CHAR;
    v_seat_type VARCHAR;
    v_section VARCHAR;

BEGIN

    FOR v_row IN 1..5 LOOP

        v_row_letter := CHR(64 + v_row);

        IF v_row <= 2 THEN
            v_seat_type := 'VIP';
            v_section := 'Front';
        ELSIF v_row <= 4 THEN
            v_seat_type := 'Premium';
            v_section := 'Middle';
        ELSE
            v_seat_type := 'Regular';
            v_section := 'Rear';
        END IF;

        FOR v_seat IN 1..6 LOOP

            INSERT INTO seat (
                row,
                number,
                section,
                seat_type,
                venue_id
            )
            VALUES (
                v_row_letter,
                v_seat,
                v_section,
                v_seat_type,
                1
            );

        END LOOP;

    END LOOP;

    FOR v_row IN 1..10 LOOP

        v_row_letter := CHR(64 + v_row);

        IF v_row <= 3 THEN
            v_seat_type := 'VIP';
            v_section := 'Front';
        ELSIF v_row <= 6 THEN
            v_seat_type := 'Premium';
            v_section := 'Middle';
        ELSE
            v_seat_type := 'Regular';
            v_section := 'Rear';
        END IF;

        FOR v_seat IN 1..6 LOOP

            INSERT INTO seat (
                row,
                number,
                section,
                seat_type,
                venue_id
            )
            VALUES (
                v_row_letter,
                v_seat,
                v_section,
                v_seat_type,
                2
            );

        END LOOP;

    END LOOP;

END;
$$;

-- 11.2. Schedule Event

CALL schedule_event(1);

SELECT * FROM event WHERE event_id = 1;

-- 11.3. Optionally could cancel scheduled events before ticket sale starts

CALL publish_event(2);
CALL apply_to_event(
    p_user_id := 2,
    p_event_id := 2
);
CALL approve_organizer(2, 2);
CALL schedule_event(2);
CALL cancel_event(2);

SELECT * FROM event WHERE event_id = 2;

-- 12. Browse Scheduled Events

SELECT * FROM browse_scheduled_events();

-- 13. View Tickets for a Specific Event

SELECT * FROM view_event_tickets(1);

-- 14. Reserve Tickets (with Concurrency Demo)

-- Session A

BEGIN;

CALL reserve_ticket(
    p_user_id := 1,
    p_ticket_id := 1
);

COMMIT;

-- Session B

BEGIN;

CALL reserve_ticket(
    p_user_id := 2,
    p_ticket_id := 1
);

COMMIT;

SELECT ticket_id, status FROM ticket WHERE ticket_id = 1;

SELECT 
    rh.user_id,
    b.name AS buyer_name,
    rh.ticket_id,
    rh.status,
    rh.reservation_datetime,
    rh.expiry_datetime
FROM reservation_history rh
    JOIN buyer b ON rh.user_id = b.user_id
        WHERE rh.ticket_id = 1;

-- 15. Complete Booking (Initial Payment)

CALL complete_booking(
    p_user_id := 1,
    p_ticket_id := 1,
    p_payment_method := 'Card'
);

SELECT ticket_id, status FROM ticket WHERE ticket_id = 1;

SELECT 
    oh.user_id,
    b.name AS buyer_name,
    oh.ticket_id,
    oh.is_current,
    oh.owned_from
FROM ownership_history oh
JOIN buyer b ON oh.user_id = b.user_id
WHERE oh.ticket_id = 1;

SELECT *
FROM transaction;

SELECT *
FROM initial_payment;

-- 16. Request Refund

CALL request_refund(
    p_user_id := 1,
    p_ticket_id := 1,
    p_reason := 'Unable to attend the event due to personal reasons.',
    p_refund_method := 'Card'
);

SELECT * FROM refund where refund_id = 1;

-- 17. Get Refund Requests

SELECT *
FROM get_refund_requests(1);

-- 18. Process Refund Requests

CALL process_refund_request(
    p_refund_id := 1,
    p_refund_status := 'Rejected'
);

SELECT *
FROM refund
WHERE refund_id = 1;

SELECT *
FROM ownership_history
WHERE ticket_id = 1;

SELECT *
FROM ticket
WHERE ticket_id = 1;

-- 19.1. List for resale 

CALL list_ticket_for_resale(
    p_user_id := 1,
    p_ticket_id := 1
);

SELECT * FROM resale_listing_history;

-- 19.2. Optionally could withdraw resale listing (with concurrency)

CALL reserve_ticket(
    p_user_id := 1,
    p_ticket_id := 2
);

CALL complete_booking(
    p_user_id := 1,
    p_ticket_id := 2,
    p_payment_method := 'Card'
);

CALL list_ticket_for_resale(
    p_user_id := 1,
    p_ticket_id := 2
);

-- Session A

BEGIN;

CALL withdraw_resale_listing(
    p_user_id := 1,
    p_ticket_id := 2
);

COMMIT;

-- Session B

BEGIN;

CALL purchase_resale_ticket(
    p_buyer_id := 2,
    p_ticket_id := 2,
    p_payment_method := 'JazzCash'
);

COMMIT;

SELECT * FROM resale_listing_history WHERE ticket_id = 2;

-- 20. Get Resale Tickets For Event

SELECT * FROM get_resale_tickets_for_event(1);

-- 21. Purchase Resale Ticket (with Concurrency)

-- Session A

BEGIN;

CALL purchase_resale_ticket(
    p_buyer_id := 2,
    p_ticket_id := 1,
    p_payment_method := 'JazzCash'
);

COMMIT;

-- Session B

BEGIN;

CALL purchase_resale_ticket(
    p_buyer_id := 3,
    p_ticket_id := 1,
    p_payment_method := 'JazzCash'
);

COMMIT;

SELECT * FROM ownership_history WHERE ticket_id = 1;
SELECT * FROM resale_listing_history WHERE ticket_id = 1;
SELECT * FROM resale_payment;

-- 22.1. Required update before start event

UPDATE event
SET
    sale_start_datetime = CURRENT_TIMESTAMP - INTERVAL '3 days',
    sale_end_datetime   = CURRENT_TIMESTAMP - INTERVAL '2 hours',
    start_datetime      = CURRENT_TIMESTAMP - INTERVAL '1 hour',
    end_datetime        = CURRENT_TIMESTAMP + INTERVAL '3 hours'
WHERE event_id = 1;

-- 22.2. Start Event

CALL start_event(1);

SELECT * FROM event WHERE event_id = 1;

-- 23.1. Required update before complete event

UPDATE event
SET end_datetime = CURRENT_TIMESTAMP - INTERVAL '10 minutes'
WHERE event_id = 1;

-- 23.2. Complete Event

CALL complete_event(1);

SELECT * FROM event WHERE event_id = 1;

-- 24.1. Issue Event Payment

CALL issue_event_payment(
    1,
    'Bank Transfer',
    5,
    'Excellent event management and communication throughout the event.'
);

SELECT t.*
FROM transaction t
JOIN event_payment ep
    ON t.transaction_id = ep.transaction_id
WHERE ep.event_id = 1;

SELECT *
FROM event_payment
WHERE event_id = 1;

SELECT *
FROM organization_review
WHERE event_id = 1;

-- 24.2. Update Organization Review

CALL update_organizer_review(
    p_event_id := 1,
    p_rating := 4
);

SELECT *
FROM organization_review
WHERE event_id = 1;

-- 25. View Event Payments

SELECT * FROM get_organizer_event_payments(2);

-- 26. View Performance Reviews

SELECT * FROM get_organizer_reviews(2);

-- 27. Submit Buyer Review

CALL submit_buyer_review(
    p_user_id := 2,
    p_event_id := 1,
    p_rating := 5,
    p_comment := 'Amazing experience!'
);

SELECT * FROM buyer_review where user_id = 2 and event_id = 1;

-- 28. Update Buyer Review

CALL update_buyer_review(
    p_user_id := 2,
    p_event_id := 1,
    p_rating := 4,
    p_comment := 'Updating my thoughts after some reflection.'
);

SELECT * FROM buyer_review where user_id = 2 and event_id = 1;