-- 1. Get Open Events (browse events open for management applications)

CREATE OR REPLACE FUNCTION get_open_events()
RETURNS TABLE (
    event_id INTEGER,
    title VARCHAR,
    description TEXT,
    start_datetime TIMESTAMP,
    end_datetime TIMESTAMP,
    offered_payment NUMERIC,
    organization_name VARCHAR,
    venue_name VARCHAR,
    venue_city VARCHAR,
    venue_country VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY

    SELECT
        e.event_id,
        e.title,
        e.description,
        e.start_datetime,
        e.end_datetime,
        e.offered_payment,
        o.name,
        v.name,
        v.city,
        v.country

    FROM event e
    JOIN organization o
        ON e.organization_id = o.organization_id
    JOIN venue v
        ON e.venue_id = v.venue_id

    WHERE e.status = 'Application_Open';

END;
$$;

-- 2. Get Organizer Applications (view application status)

CREATE OR REPLACE FUNCTION get_organizer_applications(
    p_user_id INTEGER
)
RETURNS TABLE (
    event_title VARCHAR,
    applied_at TIMESTAMP,
    application_status VARCHAR
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
        e.title,
        ah.applied_at,
        ah.status

    FROM application_history ah
    JOIN event e
        ON ah.event_id = e.event_id

    WHERE ah.user_id = p_user_id

    ORDER BY ah.applied_at DESC;

END;
$$;

-- 3. Get Organizer Event Payments

CREATE OR REPLACE FUNCTION get_organizer_event_payments(
    p_user_id INTEGER
)
RETURNS TABLE (
    event_title VARCHAR,
    organization_name VARCHAR,
    amount NUMERIC,
    payment_method VARCHAR,
    payment_status VARCHAR,
    date_time TIMESTAMP
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
        e.title,
        o.name,
        t.amount,
        t.payment_method,
        t.payment_status,
        t.date_time

    FROM event_payment ep
    JOIN transaction t
        ON ep.transaction_id = t.transaction_id
    JOIN event e
        ON ep.event_id = e.event_id
    JOIN organization o
        ON ep.organization_id = o.organization_id

    WHERE ep.user_id = p_user_id

    ORDER BY t.date_time DESC;

END;
$$;

-- 4. View performance reviews from organizations.

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