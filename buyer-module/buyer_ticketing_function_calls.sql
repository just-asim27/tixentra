-- Buyer Ticketing Function Calls

-- 1. Browse Scheduled Events

SELECT * FROM browse_scheduled_events();

-- 2. View Tickets for a Specific Event

-- View tickets for event 1
SELECT * FROM view_event_tickets(1);

-- View tickets for event 2
SELECT * FROM view_event_tickets(2);