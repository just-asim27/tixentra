-- 1. Browse scheduled events
CREATE OR REPLACE FUNCTION browse_scheduled_events()
RETURNS TABLE (
    event_id INTEGER,
    title VARCHAR,
    description TEXT,
    start_datetime TIMESTAMP,
    end_datetime TIMESTAMP,
    venue_name VARCHAR,
    city VARCHAR,
    country VARCHAR,
    base_price NUMERIC,
    status VARCHAR,
    total_tickets BIGINT,
    available_tickets BIGINT
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
        v.name AS venue_name,
        v.city,
        v.country,
        e.base_price,
        e.status,
        COUNT(t.ticket_id) AS total_tickets,
        COUNT(CASE WHEN t.status = 'Available' THEN 1 END) AS available_tickets
        FROM event e JOIN venue v ON e.venue_id = v.venue_id JOIN ticket t ON e.event_id = t.event_id 
          WHERE e.status = 'Scheduled' 
            AND e.sale_start_datetime <= CURRENT_TIMESTAMP
              AND e.sale_end_datetime >= CURRENT_TIMESTAMP
                GROUP BY e.event_id, v.name, v.city, v.country, e.title, e.description, e.start_datetime, e.end_datetime, e.base_price, e.status
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
    IF (SELECT COUNT(*) FROM event WHERE event_id = p_event_id) = 0 
    
    THEN
        RAISE EXCEPTION 'Event does not exist.';
    END IF;

    IF (SELECT COUNT(*) FROM event WHERE event_id = p_event_id AND event.status = 'Scheduled') = 0 
    
    THEN
        RAISE EXCEPTION 'Only scheduled events can be viewed.';
    END IF;

    IF (SELECT COUNT(*) FROM event WHERE event_id = p_event_id AND sale_start_datetime <= CURRENT_TIMESTAMP AND sale_end_datetime >= CURRENT_TIMESTAMP) = 0
      
    THEN
        RAISE EXCEPTION 'Ticket sales are not currently open for this event.';
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