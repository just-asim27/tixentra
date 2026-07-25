-- 1. Get Resale Tickets for Event

CREATE OR REPLACE FUNCTION get_resale_tickets_for_event(
    p_event_id INTEGER
)
RETURNS TABLE (
    ticket_id INTEGER,
    seat_row VARCHAR,
    seat_number INTEGER,
    seat_section VARCHAR,
    seat_type VARCHAR,
    listed_price NUMERIC
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

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
          AND status = 'Scheduled'
    ) = 0 THEN
        RAISE EXCEPTION 'Event is not scheduled.';
    END IF;

    RETURN QUERY

    SELECT
        t.ticket_id,
        s.row,
        s.number,
        s.section,
        s.seat_type,
        rlh.listed_price

    FROM resale_listing_history rlh
    JOIN ticket t
        ON rlh.ticket_id = t.ticket_id
    JOIN seat s
        ON t.seat_id = s.seat_id

    WHERE t.event_id = p_event_id
      AND rlh.status = 'Listed'

    ORDER BY rlh.listed_price ASC;

END;
$$;