-- 1. Register Buyers

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

SELECT * FROM buyer;

-- 2. Reserve Tickets (with Concurrency Demo)

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

-- 3. Complete Booking (Initial Payment)

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

-- 4. Request Refund

CALL request_refund(
    p_user_id := 1,
    p_ticket_id := 1,
    p_reason := 'Unable to attend the event due to personal reasons.',
    p_refund_method := 'Card'
);

SELECT * FROM refund where refund_id = 1;