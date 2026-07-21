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

-- 2. Get Organizer Reviews

CREATE OR REPLACE FUNCTION get_organizer_reviews(
    p_user_id INTEGER
)
RETURNS TABLE (
    organization_name VARCHAR,
    event_title VARCHAR,
    rating INTEGER,
    comment TEXT,
    review_date TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF (
        SELECT COUNT(*)
        FROM organizer
        WHERE user_id = p_user_id
    ) = 0 THEN
        RAISE EXCEPTION 'Organizer does not exist.';
    END IF;

    RETURN QUERY

    SELECT
        org.name,
        e.title,
        r.rating,
        r.comment,
        COALESCE(r.revised_at, r.created_at) as review_date

    FROM organization_review r
    JOIN organization org
        ON r.organization_id = org.organization_id
    JOIN event e
        ON r.event_id = e.event_id
    WHERE r.user_id = p_user_id

    ORDER BY COALESCE(r.revised_at, r.created_at) DESC;

END;
$$;

-- 3. Get Refund Requests

CREATE OR REPLACE FUNCTION get_refund_requests(
    p_event_id INTEGER
)
RETURNS TABLE (
    refund_id INTEGER,
    buyer_name VARCHAR,
    amount NUMERIC,
    refund_method VARCHAR,
    reason TEXT,
    requested_at TIMESTAMP,
    refund_status VARCHAR
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
        r.refund_id,
        b.name,
        r.amount,
        r.refund_method,
        r.reason,
        r.date_time,
        r.refund_status
    FROM refund r

    JOIN initial_payment ip
        ON r.transaction_id = ip.transaction_id

    JOIN buyer b
        ON ip.user_id = b.user_id

    JOIN ticket t
        ON ip.ticket_id = t.ticket_id

    WHERE t.event_id = p_event_id
      AND r.refund_status = 'Pending'

    ORDER BY r.date_time DESC;

END;
$$;