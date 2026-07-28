-- 1.1. Historical event data

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

-- 1.2. Sample Organization Reviews

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

-- 1.3. Sample Buyer Reviews

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

-- 1.4. Get Event Applications

SELECT *
FROM get_event_applications(1);

-- 3. Get Refund Requests

SELECT *
FROM get_refund_requests(1);