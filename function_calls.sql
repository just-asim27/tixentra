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

-- 2.1. Historical event data for reviews 

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
    'AI Developers Conference 2025',
    'A national conference for AI professionals, researchers, and software developers.',
    '2025-03-15 09:00:00',
    '2025-03-15 18:00:00',
    '2025-02-01 00:00:00',
    '2025-03-14 23:59:59',
    45000.00,
    'Completed',
    15,
    TRUE,
    10.00,
    5.00,
    80,
    60,
    18,
    1500.00,
    200.00,
    700000.00,
    1,
    1,
    1
),
(
    'Pakistan Music Festival 2025',
    'A live music festival featuring artists from across Pakistan.',
    '2025-05-20 16:00:00',
    '2025-05-20 23:30:00',
    '2025-04-01 00:00:00',
    '2025-05-19 23:59:59',
    70000.00,
    'Completed',
    10,
    FALSE,
    0.00,
    0.00,
    150,
    120,
    16,
    2500.00,
    500.00,
    1200000.00,
    2,
    2,
    2
),
(
    'Startup Innovation Expo 2025',
    'An exhibition connecting startups, investors, and technology companies.',
    '2025-08-10 10:00:00',
    '2025-08-11 17:00:00',
    '2025-06-15 00:00:00',
    '2025-08-09 23:59:59',
    35000.00,
    'Completed',
    20,
    TRUE,
    8.00,
    3.00,
    120,
    100,
    18,
    1800.00,
    250.00,
    900000.00,
    3,
    3,
    3
);

-- 2.2. Sample organization reviews

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
    6,
    1
),
(
    4,
    'Managed the event professionally and handled unexpected situations very well.',
    2,
    7,
    2
),
(
    5,
    'Outstanding coordination with vendors, speakers, and attendees.',
    3,
    8,
    3
);

-- 2.3. Get Organizer Reviews

SELECT * FROM get_organizer_reviews(1);