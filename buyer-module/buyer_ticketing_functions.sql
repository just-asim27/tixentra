-- 1. Browse Scheduled Events

CREATE OR REPLACE FUNCTION browse_scheduled_events()
RETURNS TABLE (
    event_id INTEGER,
    title VARCHAR,
    description TEXT,
    start_datetime TIMESTAMP,
    end_datetime TIMESTAMP,
    sale_start_datetime TIMESTAMP,
    sale_end_datetime TIMESTAMP,
    venue_name VARCHAR,
    city VARCHAR,
    country VARCHAR,
    base_price NUMERIC,
    is_refund_allowed BOOLEAN
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
        e.sale_start_datetime,
        e.sale_end_datetime,
        v.name,
        v.city,
        v.country,
        e.base_price,
        e.is_refund_allowed

    FROM event e
    JOIN venue v
        ON e.venue_id = v.venue_id

    WHERE e.status = 'Scheduled'

    ORDER BY e.start_datetime ASC;

END;
$$;

-- 2. View tickets for scheduled events

CREATE OR REPLACE FUNCTION view_event_tickets(
    p_event_id INTEGER
)
RETURNS TABLE (
    ticket_id INTEGER,
    "row" VARCHAR,
    number INTEGER,
    section VARCHAR,
    seat_type VARCHAR,
    price NUMERIC,
    status VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    CALL expire_reservations();

    IF (SELECT COUNT(*) FROM event WHERE event_id = p_event_id) = 0 THEN
        RAISE EXCEPTION 'Event does not exist.';
    END IF;

    IF (SELECT COUNT(*) FROM event WHERE event_id = p_event_id AND event.status = 'Scheduled') = 0 THEN
        RAISE EXCEPTION 'Only scheduled events can be viewed.';
    END IF;

    RETURN QUERY
    SELECT 
        t.ticket_id,
        s.row,
        s.number,
        s.section,
        s.seat_type,
        t.price,
        t.status
    FROM ticket t JOIN seat s ON t.seat_id = s.seat_id 
      WHERE t.event_id = p_event_id
        ORDER BY s.row, s.number;
        
END;
$$;