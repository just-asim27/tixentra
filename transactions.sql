-- Organization related transactions:

-- 1. Approve an organizer to manage a specific event.
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN;

SELECT * FROM event WHERE event_id = 1 FOR UPDATE;
SELECT * FROM application_history WHERE event_id = 1 FOR UPDATE;

-- Accept chosen application
UPDATE application_history SET status = 'Accepted' WHERE user_id = 1 AND event_id = 1;

-- Reject other applications
UPDATE application_history SET status = 'Rejected' WHERE event_id = 1 AND user_id != 1 AND status = 'Pending';

-- Assign organizer to the event
UPDATE event SET user_id = 1 WHERE event_id = 1;

-- Close the application phase
UPDATE event SET status = 'Application_Closed' WHERE event_id = 1;

COMMIT;

-- 2. Issue event payments to organizers after successful event completion.

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN;

-- Create transaction record
INSERT INTO transaction (transaction_id, amount, payment_method, date_time, payment_status) VALUES (3, 5000.00, 'Card', DEFAULT, 'Completed');

-- Create event payment record
INSERT INTO event_payment (transaction_id, user_id, event_id, organization_id) VALUES (3, 1, 1, 1);

COMMIT;

-- Buyer related transactions:

-- 3. Reserve tickets subject to event-specific reservation limits.

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN;
SELECT * FROM ticket WHERE ticket_id = 2 FOR UPDATE;
--INSERT INTO ticket (ticket_id, price, status, generated_at, event_id, seat_id) VALUES (2, 400.00, 'Available', '2026-07-15 23:59:59', 1, 2);

-- Create reservation record
INSERT INTO reservation_history (user_id, ticket_id, reservation_datetime, expiry_datetime, status) VALUES (1, 2, DEFAULT, '2026-07-30 23:59:59', 'Active');

-- Mark ticket as reserved
UPDATE ticket SET status = 'Reserved' WHERE ticket_id = 2;

COMMIT;

-- 4. Complete ticket bookings through initial payments.

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN;
SELECT * FROM ticket WHERE ticket_id = 1 FOR UPDATE;
SELECT * FROM reservation_history WHERE ticket_id = 1 FOR UPDATE;

-- Create transaction record
INSERT INTO transaction (transaction_id, amount, payment_method, date_time, payment_status) VALUES (6, 500.00, 'Card', DEFAULT, 'Completed');

-- Create initial payment record
INSERT INTO initial_payment (transaction_id, organization_id, user_id, ticket_id) VALUES (6, 1, 1, 1);

-- Convert reservation
UPDATE reservation_history SET status = 'Converted' WHERE user_id = 1 AND ticket_id = 1;

-- Create ownership record
insert into ownership_history values(6,1,'2026-07-19 23:59:59','2026-07-27 13:59:59','true');

-- Mark ticket as sold
UPDATE ticket SET status = 'Sold' WHERE ticket_id = 1;

COMMIT;

-- 5. Purchase tickets listed for resale by other buyers.

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN;
SELECT * FROM resale_listing_history WHERE ticket_id = 1 FOR UPDATE;

-- Create transaction record
INSERT INTO transaction (transaction_id, amount, payment_method, date_time, payment_status) VALUES (7, 450.00, 'Card', DEFAULT, 'Completed');

-- Create resale payment record
INSERT INTO resale_payment (transaction_id, organization_amount, seller_amount, organization_id, ticket_id, buyer_id, seller_id) VALUES (7, 45.00, 405.00, 1, 1, 2, 1);

-- Transfer ticket ownership
INSERT INTO ownership_history (user_id, ticket_id, owned_from, owned_until, is_current) VALUES (2, 1, DEFAULT, NULL, TRUE);

-- Mark resale listing as sold
UPDATE resale_listing_history SET status = 'Sold' WHERE user_id = 1 AND ticket_id = 1;

COMMIT;
