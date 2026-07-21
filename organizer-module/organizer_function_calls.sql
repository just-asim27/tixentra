-- Write your function calls here
-- 1. Browse Events Open for Applications

SELECT * FROM get_open_events();

-- 2. View Application Status

SELECT * FROM get_organizer_applications(1);
SELECT * FROM get_organizer_applications(2);

-- 3. View Event Payments

SELECT * FROM get_organizer_event_payments(2);

-- 4. View Performance Reviews

SELECT * FROM get_organizer_reviews(2);
