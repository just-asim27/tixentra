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

SELECT *
FROM get_event_applications(1);