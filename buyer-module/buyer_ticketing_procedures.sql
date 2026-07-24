-- 1. Register as a buyer

CREATE OR REPLACE PROCEDURE register_buyer(
    p_name VARCHAR,
    p_email VARCHAR,
    p_national_id VARCHAR,
    p_password VARCHAR,
    p_dob DATE,
    p_phone VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO buyer (
        name,
        email,
        national_id,
        password,
        dob,
        phone
    )
    VALUES (
        p_name,
        p_email,
        p_national_id,
        p_password,
        p_dob,
        p_phone
    );

    RAISE NOTICE 'Buyer registered successfully.';

END;
$$;

-- 5. Expire Reservation 

CREATE OR REPLACE PROCEDURE expire_reservations()
LANGUAGE plpgsql
AS $$
BEGIN

    UPDATE reservation_history
    SET status = 'Expired'
    WHERE status = 'Active'
      AND expiry_datetime <= CURRENT_TIMESTAMP;

    UPDATE ticket
    SET status = 'Available'
    WHERE ticket_id IN (
        SELECT ticket_id
        FROM reservation_history
        WHERE status = 'Expired'
    );

END;
$$;

-- 2. Reserve Ticket

CREATE OR REPLACE PROCEDURE reserve_ticket(
    p_user_id INTEGER,
    p_ticket_id INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_event_id INTEGER;
    v_ticket_status VARCHAR;
    v_max_reservations INTEGER;
    v_max_bookings INTEGER;
    v_current_reservations INTEGER;
    v_current_bookings INTEGER;
    v_reservation_expiry_duration INTEGER;
    v_min_age INTEGER;
    v_buyer_dob DATE;
BEGIN

    IF (
        SELECT COUNT(*)
        FROM buyer
        WHERE user_id = p_user_id
    ) = 0 THEN
        RAISE EXCEPTION 'Buyer does not exist.';
    END IF;

    SELECT
        t.event_id,
        t.status,
        e.max_reservations,
        e.max_bookings,
        e.reservation_expiry_duration,
        e.min_age
    INTO
        v_event_id,
        v_ticket_status,
        v_max_reservations,
        v_max_bookings,
        v_reservation_expiry_duration,
        v_min_age
    FROM ticket t
    JOIN event e
        ON t.event_id = e.event_id
    WHERE t.ticket_id = p_ticket_id
    FOR UPDATE;

    IF v_event_id IS NULL THEN
        RAISE EXCEPTION 'Ticket does not exist.';
    END IF;

    IF v_ticket_status <> 'Available' THEN
        RAISE EXCEPTION 'Ticket is not available for reservation.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = v_event_id
          AND status = 'Scheduled'
    ) = 0 THEN
        RAISE EXCEPTION 'Event is not scheduled.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = v_event_id
          AND sale_start_datetime <= CURRENT_TIMESTAMP
          AND sale_end_datetime >= CURRENT_TIMESTAMP
    ) = 0 THEN
        RAISE EXCEPTION 'Ticket sales are not currently open for this event.';
    END IF;

    SELECT COUNT(*)
    INTO v_current_reservations
    FROM reservation_history rh
    JOIN ticket t
        ON rh.ticket_id = t.ticket_id
    WHERE rh.user_id = p_user_id
      AND t.event_id = v_event_id
      AND rh.status = 'Active';

    SELECT COUNT(*)
    INTO v_current_bookings
    FROM ownership_history oh
    JOIN ticket t
        ON oh.ticket_id = t.ticket_id
    WHERE oh.user_id = p_user_id
      AND t.event_id = v_event_id
      AND oh.is_current = TRUE;

    IF v_current_reservations >= v_max_reservations THEN
        RAISE EXCEPTION
            'You have reached the maximum reservation limit for this event.';
    END IF;

    IF v_current_bookings >= v_max_bookings THEN
        RAISE EXCEPTION
            'You have reached the maximum booking limit for this event.';
    END IF;

    IF v_min_age IS NOT NULL THEN

        SELECT dob
        INTO v_buyer_dob
        FROM buyer
        WHERE user_id = p_user_id;

        IF v_buyer_dob + (v_min_age * INTERVAL '1 year') > CURRENT_DATE THEN
            RAISE EXCEPTION
                'You do not meet the minimum age requirement for this event.';
        END IF;

    END IF;

    INSERT INTO reservation_history (
        user_id,
        ticket_id,
        expiry_datetime,
        status
    )
    VALUES (
        p_user_id,
        p_ticket_id,
        CURRENT_TIMESTAMP +
        (v_reservation_expiry_duration * INTERVAL '1 minute'),
        'Active'
    );

    UPDATE ticket
    SET status = 'Reserved'
    WHERE ticket_id = p_ticket_id;

    RAISE NOTICE
        'Ticket reserved successfully. Reservation expires at %.',
        CURRENT_TIMESTAMP +
        (v_reservation_expiry_duration * INTERVAL '1 minute');

END;
$$;

-- 3. Complete Ticket Booking

CREATE OR REPLACE PROCEDURE complete_booking(
    p_user_id INTEGER,
    p_ticket_id INTEGER,
    p_payment_method VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_event_id INTEGER;
    v_ticket_status VARCHAR;
    v_ticket_price NUMERIC;
    v_organization_id INTEGER;
    v_max_bookings INTEGER;
    v_current_bookings INTEGER;
    v_transaction_id INTEGER;
BEGIN

    CALL expire_reservations();

    IF (
        SELECT COUNT(*)
        FROM buyer
        WHERE user_id = p_user_id
    ) = 0 THEN
        RAISE EXCEPTION 'Buyer does not exist.';
    END IF;

    SELECT
        t.event_id,
        t.status,
        t.price,
        e.organization_id,
        e.max_bookings
    INTO
        v_event_id,
        v_ticket_status,
        v_ticket_price,
        v_organization_id,
        v_max_bookings
    FROM ticket t
    JOIN event e
        ON t.event_id = e.event_id
    WHERE t.ticket_id = p_ticket_id;

    IF v_event_id IS NULL THEN
        RAISE EXCEPTION 'Ticket does not exist.';
    END IF;

    IF v_ticket_status <> 'Reserved' THEN
        RAISE EXCEPTION 'Ticket is not reserved.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM reservation_history
        WHERE user_id = p_user_id
          AND ticket_id = p_ticket_id
          AND status = 'Active'
    ) = 0 THEN
        RAISE EXCEPTION 'This ticket is not reserved by the buyer.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = v_event_id
          AND sale_start_datetime <= CURRENT_TIMESTAMP
          AND sale_end_datetime >= CURRENT_TIMESTAMP
    ) = 0 THEN
        RAISE EXCEPTION 'Ticket sales are not currently open for this event.';
    END IF;

    SELECT COUNT(*)
    INTO v_current_bookings
    FROM ownership_history oh
    JOIN ticket t
        ON oh.ticket_id = t.ticket_id
    WHERE oh.user_id = p_user_id
      AND t.event_id = v_event_id
      AND oh.is_current = TRUE;

    IF v_current_bookings >= v_max_bookings THEN
        RAISE EXCEPTION
            'You have reached the maximum booking limit for this event.';
    END IF;

    INSERT INTO transaction (
        amount,
        payment_method,
        payment_status
    )
    VALUES (
        v_ticket_price,
        p_payment_method,
        'Completed'
    )
    RETURNING transaction_id
    INTO v_transaction_id;

    INSERT INTO initial_payment (
        transaction_id,
        organization_id,
        user_id,
        ticket_id
    )
    VALUES (
        v_transaction_id,
        v_organization_id,
        p_user_id,
        p_ticket_id
    );

    UPDATE reservation_history
    SET status = 'Converted'
    WHERE user_id = p_user_id
      AND ticket_id = p_ticket_id
      AND status = 'Active';

    INSERT INTO ownership_history (
        user_id,
        ticket_id,
        is_current
    )
    VALUES (
        p_user_id,
        p_ticket_id,
        TRUE
    );

    UPDATE ticket
    SET status = 'Sold'
    WHERE ticket_id = p_ticket_id;

    RAISE NOTICE
        'Booking completed successfully. Transaction ID: %',
        v_transaction_id;

END;
$$;

-- 4. Request Refund

CREATE OR REPLACE PROCEDURE request_refund(
    p_user_id INTEGER,
    p_ticket_id INTEGER,
    p_reason TEXT,
    p_refund_method VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_event_id INTEGER;
    v_event_start_datetime TIMESTAMP;
    v_ticket_price NUMERIC;
    v_transaction_id INTEGER;
    v_refund_id INTEGER;
BEGIN

    IF (
        SELECT COUNT(*)
        FROM buyer
        WHERE user_id = p_user_id
    ) = 0 THEN
        RAISE EXCEPTION 'Buyer does not exist.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM ticket
        WHERE ticket_id = p_ticket_id
    ) = 0 THEN
        RAISE EXCEPTION 'Ticket does not exist.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM ownership_history
        WHERE user_id = p_user_id
          AND ticket_id = p_ticket_id
          AND is_current = TRUE
    ) = 0 THEN
        RAISE EXCEPTION 'The buyer does not currently own this ticket.';
    END IF;

    SELECT
        event_id,
        price
    INTO
        v_event_id,
        v_ticket_price
    FROM ticket
    WHERE ticket_id = p_ticket_id;

    SELECT start_datetime
    INTO v_event_start_datetime
    FROM event
    WHERE event_id = v_event_id;

    IF CURRENT_TIMESTAMP >= v_event_start_datetime THEN
        RAISE EXCEPTION
            'Refunds cannot be requested after the event has started.';
    END IF;

    SELECT transaction_id
    INTO v_transaction_id
    FROM initial_payment
    WHERE ticket_id = p_ticket_id;

    IF (
        SELECT COUNT(*)
        FROM refund
        WHERE transaction_id = v_transaction_id
    ) > 0 THEN
        RAISE EXCEPTION
            'A refund request has already been submitted for this ticket.';
    END IF;

    INSERT INTO refund (
        amount,
        refund_method,
        refund_status,
        reason,
        transaction_id
    )
    VALUES (
        v_ticket_price,
        p_refund_method,
        'Pending',
        p_reason,
        v_transaction_id
    )
    RETURNING refund_id
    INTO v_refund_id;

    RAISE NOTICE
        'Refund request submitted successfully. Refund ID: %',
        v_refund_id;

END;
$$;
