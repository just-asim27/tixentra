-- 1. Organizer Registrations

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

-- 2. Apply to Event

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

CALL apply_to_event(
    p_user_id := 2,
    p_event_id := 2
);

SELECT * FROM application_history;