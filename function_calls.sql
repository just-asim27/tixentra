-- 1.1. Sample data for organizers

INSERT INTO organizer (
    name,
    email,
    national_id,
    password,
    dob,
    phone
)
VALUES
(
    'Ali Hassan',
    'ali.hassan@email.com',
    '12345-1234567-1',
    'AliPass123',
    '1998-05-14',
    '0301-1234567'
),
(
    'Ahmed Raza',
    'ahmed.raza@email.com',
    '23456-2345678-2',
    'AhmedPass456',
    '1997-09-21',
    '0302-2345678'
),
(
    'Fatima Noor',
    'fatima.noor@email.com',
    '34567-3456789-3',
    'FatimaPass789',
    '1999-02-10',
    '0303-3456789'
);

-- 1.2. Sample applications data

INSERT INTO application_history (
    user_id,
    event_id,
    applied_at,
    status
)
VALUES
(
    1,
    1,
    DEFAULT,
    'Pending'
),
(
    2,
    1,
    DEFAULT,
    'Pending'
),
(
    3,
    1,
    DEFAULT,
    'Pending'
),
(
    2,
    2,
    DEFAULT,
    'Pending'
);

-- 1.3. Get Event Applications

SELECT *
FROM get_event_applications(1);

-- 2.1. Historical Event Data for Reviews

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
    3,
    1,
    3
);

INSERT INTO sports (
    event_id,
    sport_type,
    home_team,
    away_team,
    competition_name
)
VALUES
(
    3,
    'Cricket',
    'Pakistan',
    'India',
    'Asia Cup 2025'
),
(
    4,
    'Cricket',
    'England',
    'Australia',
    'World T20 Series 2025'
),
(
    5,
    'Cricket',
    'South Africa',
    'New Zealand',
    'Champions Trophy 2025'
);

-- 2.2. Sample Organization Reviews

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
    'Excellent event management and communication throughout the event.',
    1,
    3,
    1
),
(
    4,
    'Managed the event professionally and handled unexpected situations very well.',
    2,
    4,
    2
),
(
    5,
    'Outstanding coordination with players, officials, and event logistics.',
    3,
    5,
    3
);

-- 2.3. Get Organizer Reviews

SELECT * FROM get_organizer_reviews(2);

-- 3.1. Sample buyer data

INSERT INTO buyer (
    name,
    email,
    national_id,
    password,
    dob,
    phone
)
VALUES
(
    'Ali Khan',
    'ali.khan@example.com',
    '35202-1234567-1',
    'Ali@123',
    '2000-05-10',
    '0300-1234567'
);

-- 3.2. Sample transaction data

INSERT INTO transaction (
    amount,
    payment_method,
    payment_status
)
VALUES
(
    2200.00,
    'Card',
    'Completed'
);

INSERT INTO initial_payment (
    transaction_id,
    organization_id,
    user_id,
    ticket_id
)
VALUES
(
    1,
    1,
    1,
    1
);

UPDATE ticket
SET status = 'Sold'
WHERE ticket_id = 1;

-- 3.3. Sample ownership data

INSERT INTO ownership_history (
    user_id,
    ticket_id,
    is_current
)
VALUES
(
    1,
    1,
    TRUE
);

-- 3.4. Sample refund data

INSERT INTO refund (
    amount,
    refund_method,
    refund_status,
    reason,
    transaction_id
)
VALUES
(
    2200.00,
    'Card',
    'Pending',
    'Unable to attend the event due to personal reasons.',
    1
);

-- 3.5. Get Refund Requests

SELECT *
FROM get_refund_requests(1);