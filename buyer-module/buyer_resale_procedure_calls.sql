-- 1. List for resale 

CALL list_ticket_for_resale(
    p_user_id := 1,
    p_ticket_id := 1,
    p_listed_price := 150.00
);

SELECT * FROM resale_listing_history;

-- 3. Purchase Resale Ticket (with Concurrency)

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

-- 2. Withdraw Resale Listing (with Concurrency)

-- Session A

BEGIN;

CALL withdraw_resale_listing(
    p_user_id := 1,
    p_ticket_id := 1
);

COMMIT;

-- Session B

BEGIN;

CALL purchase_resale_ticket(
    p_buyer_id := 2,
    p_ticket_id := 1,
    p_payment_method := 'JazzCash'
);

COMMIT;

SELECT * FROM resale_listing_history WHERE ticket_id = 1;

-- 4. Submit Buyer Review

CALL submit_buyer_review(
    p_user_id := 2,
    p_event_id := 1,
    p_rating := 5,
    p_comment := 'Amazing concert experience!'
);

SELECT * FROM buyer_review;

-- 5. Update Buyer Review

CALL update_buyer_review(
    p_user_id := 2,
    p_event_id := 1,
    p_rating := 4,
    p_comment := 'Updating my thoughts after some reflection.'
);

SELECT * FROM buyer_review;