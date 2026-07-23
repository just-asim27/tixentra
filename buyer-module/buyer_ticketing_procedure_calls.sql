
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


-- 2. Reserve Tickets (with Concurrency)

-- First, check available tickets
SELECT ticket_id, status, price, row, number, section, seat_type FROM view_event_tickets(1) WHERE status = 'Available';

-- Reserve a ticket (Buyer 1 reserves ticket_id 1)
CALL reserve_ticket(1, 1);

-- Check ticket status after reservation
SELECT ticket_id, status FROM ticket WHERE ticket_id = 1;

-- Check reservation history
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

-- Complete the booking
CALL complete_booking(
    p_user_id := 1,
    p_ticket_id := 1,
    p_payment_method := 'Card'
);

-- Check ticket status after booking
SELECT ticket_id, status FROM ticket WHERE ticket_id = 1;

-- Check ownership
SELECT 
    oh.user_id,
    b.name AS buyer_name,
    oh.ticket_id,
    oh.is_current,
    oh.owned_from
FROM ownership_history oh
JOIN buyer b ON oh.user_id = b.user_id
WHERE oh.ticket_id = 1;

-- Check transaction
SELECT * FROM transaction ORDER BY transaction_id DESC LIMIT 1;
SELECT * FROM initial_payment ORDER BY transaction_id DESC LIMIT 1;


-- 4. Request Refund

-- Request refund for the ticket
CALL request_refund(
    p_user_id := 1,
    p_ticket_id := 1,
    p_reason := 'Unable to attend the event due to personal reasons.',
    p_refund_method := 'Card'
);

-- Check refund requests
SELECT 
    r.refund_id,
    r.amount,
    r.refund_method,
    r.refund_status,
    r.reason,
    r.date_time,
    ip.user_id AS buyer_id,
    b.name AS buyer_name,
    ip.ticket_id
FROM refund r
JOIN initial_payment ip ON r.transaction_id = ip.transaction_id
JOIN buyer b ON ip.user_id = b.user_id
ORDER BY r.date_time DESC;