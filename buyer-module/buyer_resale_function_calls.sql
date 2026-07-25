-- Write your functions calls here
-- HOW TO RUN: This is step 10, the LAST step, and must be run
-- immediately after buyer_resale_procedure_calls.sql (step 9) in the
-- same database session/connection (it depends on the buyers, ticket
-- and event that step 9 creates):
--   1. schema/schema.sql
--   2. schema/data_validation_triggers.sql
--   3. organization-module/organization_procedures.sql
--   4. organization-module/organization_functions.sql
--   5. organizer-module/organizer_procedures.sql
--   6. organizer-module/organizer_functions.sql
--   7. buyer-module/buyer_resale_procedures.sql
--   8. buyer-module/buyer_resale_functions.sql
--   9. buyer-module/buyer_resale_procedure_calls.sql
--  10. buyer-module/buyer_resale_function_calls.sql   <-- THIS FILE
--
-- EXPECTED OUTPUT:
--   - Section 1.1: NOTICE "Ticket listed for resale successfully." (Bilal
--     re-lists ticket 1, since by the end of step 9 it had already been
--     sold once and withdrawn once, leaving no active listing).
--   - Section 1.2 (Get Resale Tickets For Event): a 1-row result showing
--     ticket 1, its seat details, listed_price = 1100.00, and
--     seller_name = 'Bilal Khan'.
--   - Section 1.3: an INTENTIONAL error ("Event does not exist.") when
--     querying event_id 999, demonstrating the existence-check working.
--
-- 1 ERROR line is expected in this file's output, and it is a deliberate
-- validation demonstration, not a bug.
-- ============================================================================

-- 1.1. Sample data
-- Run this after buyer_resale_procedure_calls.sql. By that point ticket 1's
-- listing has already been sold/withdrawn, so Bilal (buyer 2, the current
-- owner) lists it again here to demonstrate a ticket that is actively
-- available for resale.

CALL list_ticket_for_resale(
    p_user_id := 2,
    p_ticket_id := 1,
    p_listed_price := 1100.00
);

-- 1.2. Get Resale Tickets For Event

SELECT * FROM get_resale_tickets_for_event(1);

-- 1.1. Validation demonstration: querying a non-existent event fails.

SELECT * FROM get_resale_tickets_for_event(999);