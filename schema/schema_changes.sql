-- 1. Remove the resale-related configuration columns from the Event table
ALTER TABLE event DROP COLUMN is_resale_allowed CASCADE;
ALTER TABLE event DROP COLUMN org_commission_percentage CASCADE;
ALTER TABLE event DROP COLUMN resale_profit_percentage CASCADE;

-- 2. Remove the foreign key and unwanted columns from the Resale_Payment table
ALTER TABLE resale_payment DROP COLUMN organization_id;
ALTER TABLE resale_payment DROP COLUMN organization_amount;
ALTER TABLE resale_payment DROP COLUMN seller_amount;