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
    IF p_dob + INTERVAL '13 years' > CURRENT_DATE THEN
        RAISE EXCEPTION 'Buyer must be at least 13 years old.';
    END IF;

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



-- 2. Reserve tickets

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
    -- Validate buyer exists
    IF (SELECT COUNT(*) FROM buyer WHERE user_id = p_user_id ) = 0
    THEN
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
    JOIN event e ON t.event_id = e.event_id
    WHERE t.ticket_id = p_ticket_id
    FOR UPDATE;

    -- Validate ticket exists
    IF v_event_id IS NULL 
    THEN
        RAISE EXCEPTION 'Ticket does not exist.';
    END IF;

    -- Validate ticket is available
    IF v_ticket_status != 'Available' 
    THEN
        RAISE EXCEPTION 'Ticket is not available for reservation.';
    END IF;

    -- Validate event is scheduled
    IF (SELECT COUNT(*) FROM event WHERE event_id = v_event_id AND status = 'Scheduled') = 0
    THEN
        RAISE EXCEPTION 'Event is not currently accepting reservations.';
    END IF;

    -- Validate event is within sales window
    IF ( SELECT COUNT(*) FROM event WHERE event_id = v_event_id AND sale_start_datetime <= CURRENT_TIMESTAMP AND sale_end_datetime >= CURRENT_TIMESTAMP) = 0 
    THEN
        RAISE EXCEPTION 'Ticket sales are not currently open for this event.';
    END IF;

    -- Validate event hasn't started
    IF (SELECT COUNT(*) FROM event WHERE event_id = v_event_id AND start_datetime <= CURRENT_TIMESTAMP) > 0 
    THEN
        RAISE EXCEPTION 'Event has already started.';
    END IF;

    -- Get current reservations count
    SELECT COUNT(*)
    INTO v_current_reservations
    FROM reservation_history rh
        JOIN ticket t ON rh.ticket_id = t.ticket_id
            WHERE rh.user_id = p_user_id
                AND t.event_id = v_event_id
                    AND rh.status = 'Active';

    -- Get current bookings count
    SELECT COUNT(*)
    INTO v_current_bookings
    FROM ownership_history oh
        JOIN ticket t ON oh.ticket_id = t.ticket_id
            WHERE oh.user_id = p_user_id
                AND t.event_id = v_event_id
                    AND oh.is_current = TRUE;

    -- Validate reservation limits
    IF v_current_reservations >= v_max_reservations 
    THEN
        RAISE EXCEPTION 'You have reached the maximum reservation limit for this event.';
    END IF;

    -- Validate booking limits
    IF v_current_bookings >= v_max_bookings 
    THEN
        RAISE EXCEPTION 'You have reached the maximum booking limit for this event.';
    END IF;

    -- Validate age restriction 
    IF v_min_age IS NOT NULL 
    THEN
        SELECT dob INTO v_buyer_dob FROM buyer WHERE user_id = p_user_id;

        IF v_buyer_dob + (v_min_age * INTERVAL '1 year') > CURRENT_DATE 
        THEN
            RAISE EXCEPTION 'You do not meet the minimum age requirement for this event.';
        END IF;

    END IF;

    -- Create reservation 
    INSERT INTO reservation_history (
        user_id,
        ticket_id,
        expiry_datetime,
        status
    )
    VALUES (
        p_user_id,
        p_ticket_id,
        CURRENT_TIMESTAMP + (v_reservation_expiry_duration * INTERVAL '1 minute'),
        'Active'
    );

    -- Update ticket status
    UPDATE ticket SET status = 'Reserved' WHERE ticket_id = p_ticket_id;

    RAISE NOTICE 'Ticket reserved successfully. Reservation expires at %.', 
                 CURRENT_TIMESTAMP + (v_reservation_expiry_duration * INTERVAL '1 minute');
END;
$$;




-- 3. Complete ticket bookings

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
    v_transaction_id INTEGER;
    v_reservation_user_id INTEGER;
BEGIN
    -- Validate buyer exists
    IF (SELECT COUNT(*) FROM buyer WHERE user_id = p_user_id) = 0 
    
    THEN
        RAISE EXCEPTION 'Buyer does not exist.';
    END IF;

    -- Lock the ticket for update
    SELECT 
        t.event_id,
        t.status,
        t.price,
        e.organization_id
    INTO
        v_event_id,
        v_ticket_status,
        v_ticket_price,
        v_organization_id
    FROM ticket t
    JOIN event e ON t.event_id = e.event_id
    WHERE t.ticket_id = p_ticket_id
    FOR UPDATE;

    -- Validate ticket exists
    IF v_event_id IS NULL 
    
    THEN
        RAISE EXCEPTION 'Ticket does not exist.';
    END IF;

    -- Validate ticket is reserved
    IF v_ticket_status != 'Reserved' 
    
    THEN
        RAISE EXCEPTION 'Ticket is not reserved.';
    END IF;

    -- Validate reservation belongs to the buyer
    SELECT user_id INTO v_reservation_user_id FROM reservation_history WHERE ticket_id = p_ticket_id AND status = 'Active'
    ORDER BY reservation_datetime DESC
    LIMIT 1;

    IF v_reservation_user_id IS NULL 
    
    THEN
        RAISE EXCEPTION 'No active reservation found for this ticket.';
    END IF;

    IF v_reservation_user_id != p_user_id 
    
    THEN
        RAISE EXCEPTION 'This ticket is reserved by another buyer.';
    END IF;

    -- Validate event hasn't started
    IF (SELECT COUNT(*) FROM event WHERE event_id = v_event_id AND start_datetime <= CURRENT_TIMESTAMP) > 0 
    
    THEN
        RAISE EXCEPTION 'Event has already started.';
    END IF;

    -- Validate event is within sales window
    IF (SELECT COUNT(*) FROM event WHERE event_id = v_event_id AND sale_start_datetime <= CURRENT_TIMESTAMP AND sale_end_datetime >= CURRENT_TIMESTAMP) = 0 
    
    THEN
        RAISE EXCEPTION 'Ticket sales are not currently open for this event.';
    END IF;

    -- Check booking limits
    IF (SELECT COUNT(*) FROM ownership_history oh JOIN ticket t ON oh.ticket_id = t.ticket_id WHERE oh.user_id = p_user_id AND t.event_id = v_event_id AND oh.is_current = TRUE) >= 
    (SELECT max_bookings FROM event WHERE event_id = v_event_id) 
    
    THEN
        RAISE EXCEPTION 'You have reached the maximum booking limit for this event.';
    END IF;

    -- Create transaction
    INSERT INTO transaction 
    (
        amount,
        payment_method,
        payment_status
    )
    VALUES 
    (
        v_ticket_price,
        p_payment_method,
        'Completed'
    )
    RETURNING transaction_id
    INTO v_transaction_id;

    -- Create initial payment
    INSERT INTO initial_payment 
    (
        transaction_id,
        organization_id,
        user_id,
        ticket_id
    )
    VALUES 
    (
        v_transaction_id,
        v_organization_id,
        p_user_id,
        p_ticket_id
    );

    -- Update reservation status
    UPDATE reservation_history SET status = 'Converted' WHERE user_id = p_user_id AND ticket_id = p_ticket_id AND status = 'Active';

    -- Create ownership record
    INSERT INTO ownership_history 
    (
        user_id,
        ticket_id,
        is_current
    )
    VALUES 
    (
        p_user_id,
        p_ticket_id,
        TRUE
    );

    -- Update ticket status
    UPDATE ticket SET status = 'Sold' WHERE ticket_id = p_ticket_id;

    RAISE NOTICE 'Booking completed successfully. Transaction ID: %', v_transaction_id;
END;
$$;


-- 4. Request refunds for initial payments

CREATE OR REPLACE PROCEDURE request_refund
(
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
    v_ownership_owner_id INTEGER;
BEGIN

    -- Validate buyer exists
    IF (SELECT COUNT(*) FROM buyer WHERE user_id = p_user_id) = 0 
    
    THEN
        RAISE EXCEPTION 'Buyer does not exist.';
    END IF;

    -- Validate ticket exists and is owned by the buyer
    SELECT 
        oh.user_id,
        t.event_id,
        t.price
    INTO
        v_ownership_owner_id,
        v_event_id,
        v_ticket_price
    FROM ticket t
    JOIN ownership_history oh ON t.ticket_id = oh.ticket_id
        WHERE t.ticket_id = p_ticket_id
            AND oh.is_current = TRUE;

    IF v_ownership_owner_id IS NULL 
    
    THEN
        RAISE EXCEPTION 'Ticket does not exist or is not currently owned.';
    END IF;

    IF v_ownership_owner_id != p_user_id 
    
    THEN
        RAISE EXCEPTION 'You do not own this ticket.';
    END IF;

    -- Validate event hasn't started
    SELECT start_datetime INTO v_event_start_datetime FROM event WHERE event_id = v_event_id;

    IF CURRENT_TIMESTAMP >= v_event_start_datetime 
    
    THEN
        RAISE EXCEPTION 'Refunds cannot be requested for events that have already started.';
    END IF;

    -- Check if refund already exists for this ticket
    IF (SELECT COUNT(*) FROM refund r JOIN initial_payment ip ON r.transaction_id = ip.transaction_id WHERE ip.ticket_id = p_ticket_id AND r.refund_status IN ('Pending', 'Completed')) > 0 
    
    THEN
        RAISE EXCEPTION 'A refund has already been requested for this ticket.';
    END IF;

    -- Get the initial payment transaction
    SELECT transaction_id INTO v_transaction_id FROM initial_payment WHERE ticket_id = p_ticket_id;

    -- Create refund record
    INSERT INTO refund 
    (
        amount,
        refund_method,
        refund_status,
        reason,
        transaction_id
    )
    VALUES 
    (
        v_ticket_price,
        p_refund_method,
        'Pending',
        p_reason,
        v_transaction_id
    );

    RAISE NOTICE 'Refund request submitted successfully. Refund ID: %', 
                 (SELECT refund_id FROM refund WHERE transaction_id = v_transaction_id);
END;
$$;
