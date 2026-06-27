
-- Organization related transactions:
-- 1. Approve an organizer to manage a specific event.
BEGIN;
 
select * from event where event_id = 1 for update;
select * from application_history where event_id = 1 for update;

-- Accept chosen application accept
update application_history set status='Accepted' where event_id = 1;
-- Reject other applications
update application_history set status='Rejected' where event_id != 1;

-- Assign organizer to the event
update event SET user_id = 1 where event_id = 1;

-- Close the application phase
update event SET status = 'Application_Closed' where event_id = 1;

COMMIT;


-- 2. Issue event payments to organizers after successful event completion.

BEGIN;

-- Create transaction record
insert into transaction values(2,5000.0,'Card',DEFAULT,'Completed');

-- Create event payment record
insert into event_payment values(2,1,1,1);

COMMIT;

