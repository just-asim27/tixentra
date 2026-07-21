-- Write your procedure calls here
--- 1. Organizer Registrations

CALL register_organizer(
    p_name := 'Bilal Ahmed',
    p_email := 'bilal.ahmed@example.com',
    p_national_id := '42101-1234567-1',
    p_password := 'Organizer123',
    p_dob := '1990-05-14',
    p_phone := '0311-2233445'
);

CALL register_organizer(
    p_name := 'Sana Malik',
    p_email := 'sana.malik@example.com',
    p_national_id := '35202-7654321-3',
    p_password := 'Organizer456',
    p_dob := '1988-11-02',
    p_phone := '0312-3344556'
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

SELECT * FROM application_history;
