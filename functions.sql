-- 1. Get Event Applications

CREATE OR REPLACE FUNCTION get_event_applications(
    p_event_id INTEGER
)
RETURNS TABLE (
    organizer_id INTEGER,
    organizer_name VARCHAR,
    organizer_email VARCHAR,
    organizer_phone VARCHAR,
    applied_at TIMESTAMP,
    application_status VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
    ) = 0 THEN
        RAISE EXCEPTION 'Event does not exist.';
    END IF;

    RETURN QUERY

    SELECT
        o.user_id,
        o.name,
        o.email,
        o.phone,
        ah.applied_at,
        ah.status

    FROM organizer o
    JOIN application_history ah
        ON o.user_id = ah.user_id

    WHERE ah.event_id = p_event_id

    ORDER BY ah.applied_at DESC;

END;
$$;