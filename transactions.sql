-- Organization related transactions:

-- 1. Approve an organizer to manage a specific event.

BEGIN;

-- Accept chosen application

-- Reject other applications

-- Assign organizer to the event

-- Close the application phase

COMMIT;

-- 2. Issue event payments to organizers after successful event completion.

BEGIN;

-- Create transaction record

-- Create event payment record

COMMIT;

-- Buyer related transactions:

-- 3. Reserve tickets subject to event-specific reservation limits.

BEGIN;

-- Create reservation record

-- Mark ticket as reserved

COMMIT;

-- 4. Complete ticket bookings through initial payments.

BEGIN;

-- Create transaction record

-- Create initial payment record

-- Convert reservation

-- Create ownership record

-- Mark ticket as sold

COMMIT;

-- 5. Purchase tickets listed for resale by other buyers.

BEGIN;

-- Create transaction record

-- Create resale payment record

-- Transfer ticket ownership

-- Mark resale listing as sold

COMMIT;