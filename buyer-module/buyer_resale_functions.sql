-- Write your functions here 
-- HOW TO RUN: Run this AFTER buyer_resale_procedures.sql (step 7), as
-- step 8 in the sequence below:
--   1. schema/schema.sql
--   2. schema/data_validation_triggers.sql
--   3. organization-module/organization_procedures.sql
--   4. organization-module/organization_functions.sql
--   5. organizer-module/organizer_procedures.sql
--   6. organizer-module/organizer_functions.sql
--   7. buyer-module/buyer_resale_procedures.sql
--   8. buyer-module/buyer_resale_functions.sql   <-- THIS FILE
--   9. buyer-module/buyer_resale_procedure_calls.sql
--  10. buyer-module/buyer_resale_function_calls.sql
--
-- EXPECTED OUTPUT of running this file: 1x "CREATE FUNCTION" and nothing
-- else. No data is inserted here - only get_resale_tickets_for_event is
-- created/replaced.
-- ============================================================================

-- Write your functions here

-- 1. Get Resale Tickets For Event

CREATE OR REPLACE FUNCTION get_resale_tickets_for_event(
    p_event_id INTEGER
)
RETURNS TABLE (
    ticket_id INTEGER,
    seat_row VARCHAR,
    seat_number INTEGER,
    seat_section VARCHAR,
    seat_type VARCHAR,
    listed_price NUMERIC,
    seller_name VARCHAR,
    listed_at TIMESTAMP
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
        t.ticket_id,
        s.row,
        s.number,
        s.section,
        s.seat_type,
        rlh.listed_price,
        b.name,
        rlh.listed_at

    FROM resale_listing_history rlh
    JOIN ticket t
        ON rlh.ticket_id = t.ticket_id
    JOIN seat s
        ON t.seat_id = s.seat_id
    JOIN buyer b
        ON rlh.user_id = b.user_id

    WHERE t.event_id = p_event_id
      AND rlh.status = 'Listed'

    ORDER BY rlh.listed_price ASC;

END;
$$;
