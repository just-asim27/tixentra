-- Session A

-- 3. Reserve tickets subject to event-specific reservation limits.

-- Step 1 (Start)

BEGIN;

SELECT *
FROM ticket
WHERE ticket_id = 2 FOR UPDATE;

-- Step 1 (End)

-- Step 3 (Start)

-- Create reservation record
INSERT INTO reservation_history
(user_id, ticket_id, reservation_datetime, expiry_datetime, status)
VALUES
(1, 2, DEFAULT, '2026-07-30 23:59:59', 'Active');

-- Mark ticket as reserved
UPDATE ticket
SET status = 'Reserved'
WHERE ticket_id = 2;

COMMIT;

-- Step 3 (End)

-- Session B

-- 3. Reserve tickets subject to event-specific reservation limits.

-- Step 2 (Start)

BEGIN;

SELECT * FROM ticket
WHERE ticket_id = 2 FOR UPDATE;

-- Step 2 (End)

-- Step 4 (Start)

-- Create reservation record
INSERT INTO reservation_history
(user_id, ticket_id, reservation_datetime, expiry_datetime, status)
VALUES
(2, 2, DEFAULT, '2026-07-30 23:59:59', 'Active');

-- Mark ticket as reserved
UPDATE ticket
SET status = 'Reserved'
WHERE ticket_id = 2;

COMMIT;

-- Step 4 (End)

-- Step 5 (Start)

-- Demonstration

SELECT *
FROM reservation_history
WHERE ticket_id = 2;

SELECT *
FROM ticket
WHERE ticket_id = 2;

-- Step 5 (End)

-- Session A

-- 5. Purchase tickets listed for resale by other buyers.

-- Step 1 (Start)

BEGIN;

SELECT *
FROM ownership_history
WHERE user_id = 1
  AND ticket_id = 1 FOR UPDATE;

SELECT *
FROM resale_listing_history
WHERE ticket_id = 1 FOR UPDATE;

-- Step 1 (End)

-- Step 3 (Start)

-- Create transaction record
INSERT INTO transaction
(transaction_id, amount, payment_method, date_time, payment_status)
VALUES
(7, 450.00, 'Card', DEFAULT, 'Completed');

-- Create resale payment record
INSERT INTO resale_payment
(transaction_id, organization_amount, seller_amount,
 organization_id, ticket_id, buyer_id, seller_id)
VALUES
(7, 45.00, 405.00, 1, 1, 2, 1);

-- Transfer ticket ownership
UPDATE ownership_history
SET owned_until = CURRENT_TIMESTAMP,
    is_current = FALSE
WHERE user_id = 1
  AND ticket_id = 1;

INSERT INTO ownership_history
(user_id, ticket_id, owned_from, owned_until, is_current)
VALUES
(2, 1, DEFAULT, NULL, TRUE);

-- Mark resale listing as sold
UPDATE resale_listing_history
SET status = 'Sold'
WHERE user_id = 1
  AND ticket_id = 1;

COMMIT;

-- Step 3 (End)

-- Session B

-- 5. Purchase tickets listed for resale by other buyers.

-- Step 2 (Start)

BEGIN;

SELECT *
FROM ownership_history
WHERE user_id = 1
  AND ticket_id = 1 FOR UPDATE;

SELECT *
FROM resale_listing_history
WHERE ticket_id = 1 FOR UPDATE;

-- Step 2 (End)

-- Step 4 (Start)

-- Create transaction record
INSERT INTO transaction
(transaction_id, amount, payment_method, date_time, payment_status)
VALUES
(8, 450.00, 'Card', DEFAULT, 'Completed');

-- Create resale payment record
INSERT INTO resale_payment
(transaction_id, organization_amount, seller_amount,
 organization_id, ticket_id, buyer_id, seller_id)
VALUES
(8, 45.00, 405.00, 1, 1, 3, 1);

-- Transfer ticket ownership
UPDATE ownership_history
SET owned_until = CURRENT_TIMESTAMP,
    is_current = FALSE
WHERE user_id = 1
  AND ticket_id = 1;

INSERT INTO ownership_history
(user_id, ticket_id, owned_from, owned_until, is_current)
VALUES
(3, 1, DEFAULT, NULL, TRUE);

-- Mark resale listing as sold
UPDATE resale_listing_history
SET status = 'Sold'
WHERE user_id = 1
  AND ticket_id = 1;

COMMIT;

-- Step 4 (End)

-- Step 5 (Start)

-- Demonstration

SELECT *
FROM resale_listing_history
WHERE ticket_id = 1;

SELECT *
FROM ownership_history
WHERE ticket_id = 1;

-- Step 5 (End)