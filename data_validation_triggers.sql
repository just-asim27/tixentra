CREATE OR REPLACE FUNCTION check_theater_disjoint() RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*) FROM sports WHERE event_id = NEW.event_id) > 0
       OR (SELECT COUNT(*) FROM concert WHERE event_id = NEW.event_id) > 0 THEN
        RAISE EXCEPTION 'event_id % already assigned to another event subtype', NEW.event_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_theater_disjoint
BEFORE INSERT ON theater
FOR EACH ROW EXECUTE FUNCTION check_theater_disjoint();


CREATE OR REPLACE FUNCTION check_sports_disjoint() RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*) FROM theater WHERE event_id = NEW.event_id) > 0
       OR (SELECT COUNT(*) FROM concert WHERE event_id = NEW.event_id) > 0 THEN
        RAISE EXCEPTION 'event_id % already assigned to another event subtype', NEW.event_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sports_disjoint
BEFORE INSERT ON sports
FOR EACH ROW EXECUTE FUNCTION check_sports_disjoint();


CREATE OR REPLACE FUNCTION check_concert_disjoint() RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*) FROM theater WHERE event_id = NEW.event_id) > 0
       OR (SELECT COUNT(*) FROM sports WHERE event_id = NEW.event_id) > 0 THEN
        RAISE EXCEPTION 'event_id % already assigned to another event subtype', NEW.event_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_concert_disjoint
BEFORE INSERT ON concert
FOR EACH ROW EXECUTE FUNCTION check_concert_disjoint();

CREATE OR REPLACE FUNCTION check_resale_payment_disjoint() RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*) FROM initial_payment WHERE transaction_id = NEW.transaction_id) > 0
       OR (SELECT COUNT(*) FROM event_payment WHERE transaction_id = NEW.transaction_id) > 0 THEN
        RAISE EXCEPTION 'transaction_id % already assigned to another transaction subtype', NEW.transaction_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_resale_payment_disjoint
BEFORE INSERT ON resale_payment
FOR EACH ROW EXECUTE FUNCTION check_resale_payment_disjoint();


CREATE OR REPLACE FUNCTION check_initial_payment_disjoint() RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*) FROM resale_payment WHERE transaction_id = NEW.transaction_id) > 0
       OR (SELECT COUNT(*) FROM event_payment WHERE transaction_id = NEW.transaction_id) > 0 THEN
        RAISE EXCEPTION 'transaction_id % already assigned to another transaction subtype', NEW.transaction_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_initial_payment_disjoint
BEFORE INSERT ON initial_payment
FOR EACH ROW EXECUTE FUNCTION check_initial_payment_disjoint();


CREATE OR REPLACE FUNCTION check_event_payment_disjoint() RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*) FROM resale_payment WHERE transaction_id = NEW.transaction_id) > 0
       OR (SELECT COUNT(*) FROM initial_payment WHERE transaction_id = NEW.transaction_id) > 0 THEN
        RAISE EXCEPTION 'transaction_id % already assigned to another transaction subtype', NEW.transaction_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_event_payment_disjoint
BEFORE INSERT ON event_payment
FOR EACH ROW EXECUTE FUNCTION check_event_payment_disjoint();