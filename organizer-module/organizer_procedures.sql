-- Write your procedures here
-- 1. Register Organizer

CREATE OR REPLACE PROCEDURE register_organizer(
    p_name VARCHAR,
    p_email VARCHAR,
    p_national_id VARCHAR,
    p_password VARCHAR,
    p_dob DATE,
    p_phone VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO organizer (
        name,
        email,
        national_id,
        password,
        dob,
        phone
    )
    VALUES (
        p_name,
        p_email,
        p_national_id,
        p_password,
        p_dob,
        p_phone
    );

    RAISE NOTICE 'Organizer registered successfully.';

END;
$$;

-- 2. Apply to Event

CREATE OR REPLACE PROCEDURE apply_to_event(
    p_user_id INTEGER,
    p_event_id INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN

     IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
          AND status = 'Application_Open'
    ) = 0 THEN
        RAISE EXCEPTION 'Applications are not open for this event.';
    END IF;

    INSERT INTO application_history (
        user_id,
        event_id,
        status
    )
    VALUES (
        p_user_id,
        p_event_id,
        'Pending'
    );

    RAISE NOTICE 'Application submitted successfully.';

END;
$$;
