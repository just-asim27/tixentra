-- 1. Register Organization

CREATE OR REPLACE PROCEDURE register_organization(
    p_name VARCHAR,
    p_email VARCHAR,
    p_phone VARCHAR,
    p_password VARCHAR,
    p_url VARCHAR,
    p_owner VARCHAR,
    p_registration_no VARCHAR,
    p_address VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO organization (
        name,
        email,
        phone,
        password,
        url,
        owner,
        registration_no,
        address
    )
    VALUES (
        p_name,
        p_email,
        p_phone,
        p_password,
        p_url,
        p_owner,
        p_registration_no,
        p_address
    );

    RAISE NOTICE 'Organization registered successfully.';

END;
$$;

-- 2. Create Event

CREATE OR REPLACE PROCEDURE create_event(
    p_title VARCHAR,
    p_description VARCHAR,
    p_start_datetime TIMESTAMP,
    p_end_datetime TIMESTAMP,
    p_sale_start_datetime TIMESTAMP,
    p_sale_end_datetime TIMESTAMP,
    p_offered_payment NUMERIC,
    p_reservation_expiry_duration INTEGER,
    p_is_resale_allowed BOOLEAN,
    p_org_commission_percentage NUMERIC,
    p_resale_profit_percentage NUMERIC,
    p_max_reservations INTEGER,
    p_max_bookings INTEGER,
    p_min_age INTEGER,
    p_base_price NUMERIC,
    p_increment_per_seat_type NUMERIC,
    p_budget NUMERIC,
    p_organization_id INTEGER,
    p_venue_id INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_capacity INTEGER;
BEGIN

    SELECT capacity
    INTO v_capacity
    FROM venue
    WHERE venue_id = p_venue_id;

    IF p_max_reservations > v_capacity THEN
        RAISE EXCEPTION
            'Maximum reservations cannot exceed the venue capacity.';
    END IF;

    IF p_max_bookings > v_capacity THEN
        RAISE EXCEPTION
            'Maximum bookings cannot exceed the venue capacity.';
    END IF;

    INSERT INTO event (
        title,
        description,
        start_datetime,
        end_datetime,
        sale_start_datetime,
        sale_end_datetime,
        offered_payment,
        status,
        reservation_expiry_duration,
        is_resale_allowed,
        org_commission_percentage,
        resale_profit_percentage,
        max_reservations,
        max_bookings,
        min_age,
        base_price,
        increment_per_seat_type,
        budget,
        organization_id,
        venue_id,
        user_id
    )
    VALUES (
        p_title,
        p_description,
        p_start_datetime,
        p_end_datetime,
        p_sale_start_datetime,
        p_sale_end_datetime,
        p_offered_payment,
        'Draft',
        p_reservation_expiry_duration,
        p_is_resale_allowed,
        p_org_commission_percentage,
        p_resale_profit_percentage,
        p_max_reservations,
        p_max_bookings,
        p_min_age,
        p_base_price,
        p_increment_per_seat_type,
        p_budget,
        p_organization_id,
        p_venue_id,
        NULL
    );

    RAISE NOTICE 'Event created successfully in Draft status.';

END;
$$;

-- 3. Update Event

CREATE OR REPLACE PROCEDURE update_event(
    p_event_id INTEGER,

    p_title VARCHAR DEFAULT NULL,
    p_description VARCHAR DEFAULT NULL,

    p_start_datetime TIMESTAMP DEFAULT NULL,
    p_end_datetime TIMESTAMP DEFAULT NULL,

    p_sale_start_datetime TIMESTAMP DEFAULT NULL,
    p_sale_end_datetime TIMESTAMP DEFAULT NULL,

    p_offered_payment NUMERIC DEFAULT NULL,

    p_reservation_expiry_duration INTEGER DEFAULT NULL,

    p_is_resale_allowed BOOLEAN DEFAULT NULL,

    p_org_commission_percentage NUMERIC DEFAULT NULL,
    p_resale_profit_percentage NUMERIC DEFAULT NULL,

    p_max_reservations INTEGER DEFAULT NULL,
    p_max_bookings INTEGER DEFAULT NULL,

    p_min_age INTEGER DEFAULT NULL,

    p_base_price NUMERIC DEFAULT NULL,
    p_increment_per_seat_type NUMERIC DEFAULT NULL,

    p_budget NUMERIC DEFAULT NULL,

    p_venue_id INTEGER DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_venue_id INTEGER;
    v_capacity INTEGER;
BEGIN

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
    ) = 0 THEN
        RAISE EXCEPTION 'Event does not exist.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
          AND status = 'Draft'
    ) = 0 THEN
        RAISE EXCEPTION 'Only Draft events can be updated.';
    END IF;

    IF p_venue_id IS NULL THEN

        SELECT venue_id
        INTO v_venue_id
        FROM event
        WHERE event_id = p_event_id;

    ELSE

        v_venue_id := p_venue_id;

    END IF;

    SELECT capacity
    INTO v_capacity
    FROM venue
    WHERE venue_id = v_venue_id;

    IF
        p_max_reservations IS NOT NULL
        AND p_max_reservations > v_capacity
    THEN
        RAISE EXCEPTION
            'Maximum reservations cannot exceed the venue capacity.';
    END IF;

    IF
        p_max_bookings IS NOT NULL
        AND p_max_bookings > v_capacity
    THEN
        RAISE EXCEPTION
            'Maximum bookings cannot exceed the venue capacity.';
    END IF;

    UPDATE event
    SET
        title = COALESCE(p_title, title),
        description = COALESCE(p_description, description),

        start_datetime = COALESCE(p_start_datetime, start_datetime),
        end_datetime = COALESCE(p_end_datetime, end_datetime),

        sale_start_datetime = COALESCE(p_sale_start_datetime, sale_start_datetime),
        sale_end_datetime = COALESCE(p_sale_end_datetime, sale_end_datetime),

        offered_payment = COALESCE(p_offered_payment, offered_payment),

        reservation_expiry_duration = COALESCE(
            p_reservation_expiry_duration,
            reservation_expiry_duration
        ),

        is_resale_allowed = COALESCE(
            p_is_resale_allowed,
            is_resale_allowed
        ),

        org_commission_percentage = COALESCE(
            p_org_commission_percentage,
            org_commission_percentage
        ),

        resale_profit_percentage = COALESCE(
            p_resale_profit_percentage,
            resale_profit_percentage
        ),

        max_reservations = COALESCE(
            p_max_reservations,
            max_reservations
        ),

        max_bookings = COALESCE(
            p_max_bookings,
            max_bookings
        ),

        min_age = COALESCE(
            p_min_age,
            min_age
        ),

        base_price = COALESCE(
            p_base_price,
            base_price
        ),

        increment_per_seat_type = COALESCE(
            p_increment_per_seat_type,
            increment_per_seat_type
        ),

        budget = COALESCE(
            p_budget,
            budget
        ),

        venue_id = COALESCE(
            p_venue_id,
            venue_id
        )

    WHERE event_id = p_event_id;

    RAISE NOTICE 'Event updated successfully.';

END;
$$;

-- 4. Publish Event

CREATE OR REPLACE PROCEDURE publish_event(
    p_event_id INTEGER
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

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
          AND status = 'Draft'
    ) = 0 THEN
        RAISE EXCEPTION 'Only Draft events can be published.';
    END IF;

    UPDATE event
    SET status = 'Application_Open'
    WHERE event_id = p_event_id;

    RAISE NOTICE 'Event published successfully. Applications are now open.';

END;
$$;

-- 5. Approve Organizer

CREATE OR REPLACE PROCEDURE approve_organizer(
    p_user_id INTEGER,
    p_event_id INTEGER
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

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
          AND status = 'Application_Open'
    ) = 0 THEN
        RAISE EXCEPTION 'Applications are not open for this event.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM organizer
        WHERE user_id = p_user_id
    ) = 0 THEN
        RAISE EXCEPTION 'Organizer does not exist.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM application_history
        WHERE user_id = p_user_id
          AND event_id = p_event_id
          AND status = 'Pending'
    ) = 0 THEN
        RAISE EXCEPTION 'Pending application not found.';
    END IF;

    UPDATE application_history
    SET status = 'Accepted'
    WHERE user_id = p_user_id
      AND event_id = p_event_id;

    UPDATE application_history
    SET status = 'Rejected'
    WHERE event_id = p_event_id
      AND user_id <> p_user_id
      AND status = 'Pending';

    UPDATE event
    SET
        user_id = p_user_id,
        status = 'Application_Closed'
    WHERE event_id = p_event_id;

    RAISE NOTICE 'Organizer approved successfully. Event applications are now closed.';

END;
$$;

-- 6. Schedule Event

CREATE OR REPLACE PROCEDURE schedule_event(
    p_event_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_status VARCHAR;
    v_user_id INT;
    v_start_datetime TIMESTAMP;

    v_venue_id INT;
    v_base_price NUMERIC;
    v_increment NUMERIC;

    v_seat_id INT;
    v_seat_type VARCHAR;

    v_ticket_price NUMERIC;

BEGIN

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
    ) = 0 THEN
        RAISE EXCEPTION 'Event does not exist.';
    END IF;

    SELECT
        status,
        user_id,
        start_datetime,
        venue_id,
        base_price,
        increment_per_seat_type
    INTO
        v_status,
        v_user_id,
        v_start_datetime,
        v_venue_id,
        v_base_price,
        v_increment
    FROM event
    WHERE event_id = p_event_id;

    IF v_status <> 'Application_Closed' THEN
        RAISE EXCEPTION
            'Event must be in Application_Closed status.';
    END IF;

    IF v_user_id IS NULL THEN
        RAISE EXCEPTION
            'No organizer has been assigned to this event.';
    END IF;

    IF CURRENT_TIMESTAMP >= v_start_datetime THEN
        RAISE EXCEPTION
            'The event has already started.';
    END IF;

    UPDATE event
    SET status = 'Scheduled'
    WHERE event_id = p_event_id;

    FOR v_seat_id, v_seat_type IN

        SELECT
            seat_id,
            seat_type
        FROM seat
        WHERE venue_id = v_venue_id

    LOOP

        IF v_seat_type = 'Regular' THEN

            v_ticket_price := v_base_price;

        ELSIF v_seat_type = 'Premium' THEN

            v_ticket_price := v_base_price + v_increment;

        ELSE

            v_ticket_price := v_base_price + (2 * v_increment);

        END IF;

        INSERT INTO ticket (
            price,
            status,
            event_id,
            seat_id
        )
        VALUES (
            v_ticket_price,
            'Available',
            p_event_id,
            v_seat_id
        );

    END LOOP;

END;
$$;

-- 7. Start Event 

CREATE OR REPLACE PROCEDURE start_event(
    p_event_id INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_status VARCHAR;
    v_start_datetime TIMESTAMP;
    v_end_datetime TIMESTAMP;
BEGIN

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
    ) = 0 THEN
        RAISE EXCEPTION 'Event does not exist.';
    END IF;

    SELECT
        status,
        start_datetime,
        end_datetime
    INTO
        v_status,
        v_start_datetime,
        v_end_datetime
    FROM event
    WHERE event_id = p_event_id;

    IF v_status <> 'Scheduled' THEN
        RAISE EXCEPTION
            'Only scheduled events can be started.';
    END IF;

    IF CURRENT_TIMESTAMP < v_start_datetime THEN
        RAISE EXCEPTION
            'The event cannot be started before its scheduled start time.';
    END IF;

    IF CURRENT_TIMESTAMP >= v_end_datetime THEN
        RAISE EXCEPTION
            'The event cannot be started because its scheduled end time has already passed.';
    END IF;

    UPDATE event
    SET status = 'Active'
    WHERE event_id = p_event_id;

END;
$$;

-- 8. Complete Event 

CREATE OR REPLACE PROCEDURE complete_event(
    p_event_id INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
    ) = 0 THEN
        RAISE EXCEPTION 'The event does not exist.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
          AND status = 'Active'
    ) = 0 THEN
        RAISE EXCEPTION 'Only active events can be completed.';
    END IF;

    IF (
        SELECT end_datetime
        FROM event
        WHERE event_id = p_event_id
    ) > CURRENT_TIMESTAMP THEN
        RAISE EXCEPTION 'The event cannot be completed before its end time.';
    END IF;

    UPDATE event
    SET status = 'Completed'
    WHERE event_id = p_event_id;

    RAISE NOTICE 'Event completed successfully.';

END;
$$;

-- 9. Cancel Event

CREATE OR REPLACE PROCEDURE cancel_event(
    p_event_id INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
    ) = 0 THEN
        RAISE EXCEPTION 'The event does not exist.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
          AND status = 'Scheduled'
    ) = 0 THEN
        RAISE EXCEPTION 'Only scheduled events can be cancelled.';
    END IF;

    IF CURRENT_TIMESTAMP >= (
        SELECT sale_start_datetime
        FROM event
        WHERE event_id = p_event_id
    ) THEN
        RAISE EXCEPTION 'The event cannot be cancelled after ticket sales have started.';
    END IF;

    UPDATE event
    SET status = 'Cancelled'
    WHERE event_id = p_event_id;

    RAISE NOTICE 'Event cancelled successfully.';

END;
$$;

-- 10. Issue Event Payment

CREATE OR REPLACE PROCEDURE issue_event_payment(
    p_event_id INTEGER,
    p_payment_method VARCHAR,
    p_rating INTEGER,
    p_comment TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_transaction_id INTEGER;
    v_amount NUMERIC;
    v_user_id INTEGER;
    v_organization_id INTEGER;
BEGIN

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
    ) = 0 THEN
        RAISE EXCEPTION 'The event does not exist.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
          AND status = 'Completed'
    ) = 0 THEN
        RAISE EXCEPTION 'Payment can only be issued for completed events.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
          AND user_id IS NOT NULL
    ) = 0 THEN
        RAISE EXCEPTION 'No organizer has been assigned to this event.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM event_payment
        WHERE event_id = p_event_id
    ) > 0 THEN
        RAISE EXCEPTION 'Payment has already been issued for this event.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM organization_review
        WHERE event_id = p_event_id
    ) > 0 THEN
        RAISE EXCEPTION 'A review has already been submitted for this event.';
    END IF;

    SELECT
        offered_payment,
        user_id,
        organization_id
    INTO
        v_amount,
        v_user_id,
        v_organization_id
    FROM event
    WHERE event_id = p_event_id;

    INSERT INTO transaction (
        amount,
        payment_method,
        payment_status
    )
    VALUES (
        v_amount,
        p_payment_method,
        'Completed'
    )
    RETURNING transaction_id
    INTO v_transaction_id;

    INSERT INTO event_payment (
        transaction_id,
        user_id,
        event_id,
        organization_id
    )
    VALUES (
        v_transaction_id,
        v_user_id,
        p_event_id,
        v_organization_id
    );

    INSERT INTO organization_review (
        rating,
        comment,
        user_id,
        event_id,
        organization_id
    )
    VALUES (
        p_rating,
        p_comment,
        v_user_id,
        p_event_id,
        v_organization_id
    );

    RAISE NOTICE 'Payment issued successfully and organizer review submitted.';

END;
$$;

-- 11. Update Organization Review

CREATE OR REPLACE PROCEDURE update_organizer_review(
    p_event_id INTEGER,
    p_rating INTEGER DEFAULT NULL,
    p_comment TEXT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
    ) = 0 THEN
        RAISE EXCEPTION 'The event does not exist.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM organization_review
        WHERE event_id = p_event_id
    ) = 0 THEN
        RAISE EXCEPTION 'No review exists for this event.';
    END IF;

    UPDATE organization_review
    SET
        rating = COALESCE(
            p_rating,
            rating
        ),

        comment = COALESCE(
            p_comment,
            comment
        ),

        revised_at = CURRENT_TIMESTAMP

    WHERE event_id = p_event_id;

    RAISE NOTICE 'Organizer review updated successfully.';

END;
$$;