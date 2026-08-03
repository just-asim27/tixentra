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
    p_is_refund_allowed BOOLEAN,
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

    IF (
        SELECT COUNT(*)
        FROM event e
        WHERE e.venue_id = p_venue_id
        AND e.status IN (
            'Application_Open',
            'Application_Closed',
            'Scheduled',
            'Active'
        )
        AND e.start_datetime < p_end_datetime
        AND e.end_datetime > p_start_datetime
    ) > 0 THEN
    RAISE EXCEPTION
        'Another event is already scheduled at the selected venue during the specified time.';
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
        is_refund_allowed,
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
        p_is_refund_allowed,
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
    p_is_refund_allowed BOOLEAN DEFAULT NULL,

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

    IF (
        SELECT COUNT(*)
        FROM event e
        WHERE e.venue_id = p_venue_id
        AND e.status IN (
            'Application_Open',
            'Application_Closed',
            'Scheduled',
            'Active'
        )
        AND e.start_datetime < p_end_datetime
        AND e.end_datetime > p_start_datetime
    ) > 0 THEN
    RAISE EXCEPTION
        'Another event is already scheduled at the selected venue during the specified time.';
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

        is_refund_allowed = COALESCE(
            p_is_refund_allowed,
            is_refund_allowed
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

    IF (
        SELECT COUNT(*)
        FROM theater
        WHERE event_id = p_event_id
    ) = 0
    AND (
        SELECT COUNT(*)
        FROM sports
        WHERE event_id = p_event_id
    ) = 0
    AND (
        SELECT COUNT(*)
        FROM concert
        WHERE event_id = p_event_id
    ) = 0 THEN
        RAISE EXCEPTION 'An event must belong to a subtype before it can be published.';
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

-- 12. Create Sports 

CREATE OR REPLACE PROCEDURE create_sports(
    p_event_id INTEGER,
    p_sport_type VARCHAR,
    p_home_team VARCHAR,
    p_away_team VARCHAR,
    p_competition_name VARCHAR
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
        RAISE EXCEPTION 'Sports details can only be added to Draft events.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM theater
        WHERE event_id = p_event_id
    ) > 0
    OR (
        SELECT COUNT(*)
        FROM concert
        WHERE event_id = p_event_id
    ) > 0
    OR (
        SELECT COUNT(*)
        FROM sports
        WHERE event_id = p_event_id
    ) > 0 THEN
        RAISE EXCEPTION 'This event has already been assigned a subtype.';
    END IF;

    INSERT INTO sports (
        event_id,
        sport_type,
        home_team,
        away_team,
        competition_name
    )
    VALUES (
        p_event_id,
        p_sport_type,
        p_home_team,
        p_away_team,
        p_competition_name
    );

    RAISE NOTICE 'Sports details added successfully.';

END;
$$;

-- 13. Update Sports 

CREATE OR REPLACE PROCEDURE update_sports(
    p_event_id INTEGER,
    p_sport_type VARCHAR DEFAULT NULL,
    p_home_team VARCHAR DEFAULT NULL,
    p_away_team VARCHAR DEFAULT NULL,
    p_competition_name VARCHAR DEFAULT NULL
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
        FROM sports
        WHERE event_id = p_event_id
    ) = 0 THEN
        RAISE EXCEPTION 'Sports details do not exist for this event.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
          AND status = 'Draft'
    ) = 0 THEN
        RAISE EXCEPTION 'Sports details can only be updated for Draft events.';
    END IF;

    UPDATE sports
    SET
        sport_type = COALESCE(p_sport_type, sport_type),
        home_team = COALESCE(p_home_team, home_team),
        away_team = COALESCE(p_away_team, away_team),
        competition_name = COALESCE(p_competition_name, competition_name)
    WHERE event_id = p_event_id;

    RAISE NOTICE 'Sports details updated successfully.';

END;
$$;

-- 14. Create Concert

CREATE OR REPLACE PROCEDURE create_concert(
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
        RAISE EXCEPTION 'Concert details can only be added to Draft events.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM theater
        WHERE event_id = p_event_id
    ) > 0
    OR (
        SELECT COUNT(*)
        FROM sports
        WHERE event_id = p_event_id
    ) > 0
    OR (
        SELECT COUNT(*)
        FROM concert
        WHERE event_id = p_event_id
    ) > 0 THEN
        RAISE EXCEPTION 'This event has already been assigned a subtype.';
    END IF;

    INSERT INTO concert (
        event_id
    )
    VALUES (
        p_event_id
    );

    RAISE NOTICE 'Concert created successfully.';

END;
$$;

-- 15. Add Concert Artist 

CREATE OR REPLACE PROCEDURE add_concert_artist(
    p_event_id INTEGER,
    p_artist_name VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF (
        SELECT COUNT(*)
        FROM concert
        WHERE event_id = p_event_id
    ) = 0 THEN
        RAISE EXCEPTION 'Concert does not exist.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
          AND status = 'Draft'
    ) = 0 THEN
        RAISE EXCEPTION 'Artists can only be added to Draft events.';
    END IF;

    INSERT INTO concert_artist (
        event_id,
        artist_name
    )
    VALUES (
        p_event_id,
        p_artist_name
    );

    RAISE NOTICE 'Concert artist added successfully.';

END;
$$;

-- 16. Remove Concert Artist

CREATE OR REPLACE PROCEDURE remove_concert_artist(
    p_event_id INTEGER,
    p_artist_name VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF (
        SELECT COUNT(*)
        FROM concert
        WHERE event_id = p_event_id
    ) = 0 THEN
        RAISE EXCEPTION 'Concert does not exist.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
          AND status = 'Draft'
    ) = 0 THEN
        RAISE EXCEPTION 'Artists can only be removed from Draft events.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM concert_artist
        WHERE event_id = p_event_id
          AND artist_name = p_artist_name
    ) = 0 THEN
        RAISE EXCEPTION 'Artist does not exist for this concert.';
    END IF;

    DELETE FROM concert_artist
    WHERE event_id = p_event_id
      AND artist_name = p_artist_name;

    RAISE NOTICE 'Concert artist removed successfully.';

END;
$$;

-- 17. Add Concert Genre

CREATE OR REPLACE PROCEDURE add_concert_genre(
    p_event_id INTEGER,
    p_genre VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF (
        SELECT COUNT(*)
        FROM concert
        WHERE event_id = p_event_id
    ) = 0 THEN
        RAISE EXCEPTION 'Concert does not exist.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
          AND status = 'Draft'
    ) = 0 THEN
        RAISE EXCEPTION 'Genres can only be added to Draft events.';
    END IF;

    INSERT INTO concert_genre (
        event_id,
        genre
    )
    VALUES (
        p_event_id,
        p_genre
    );

    RAISE NOTICE 'Concert genre added successfully.';

END;
$$;

-- 18. Remove Concert Genre

CREATE OR REPLACE PROCEDURE remove_concert_genre(
    p_event_id INTEGER,
    p_genre VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF (
        SELECT COUNT(*)
        FROM concert
        WHERE event_id = p_event_id
    ) = 0 THEN
        RAISE EXCEPTION 'Concert does not exist.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
          AND status = 'Draft'
    ) = 0 THEN
        RAISE EXCEPTION 'Genres can only be removed from Draft events.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM concert_genre
        WHERE event_id = p_event_id
          AND genre = p_genre
    ) = 0 THEN
        RAISE EXCEPTION 'Genre does not exist for this concert.';
    END IF;

    DELETE FROM concert_genre
    WHERE event_id = p_event_id
      AND genre = p_genre;

    RAISE NOTICE 'Concert genre removed successfully.';

END;
$$;

-- 19. Create Theater

CREATE OR REPLACE PROCEDURE create_theater(
    p_event_id INTEGER,
    p_show_name VARCHAR,
    p_language VARCHAR
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
        RAISE EXCEPTION 'Theater details can only be added to Draft events.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM theater
        WHERE event_id = p_event_id
    ) > 0
    OR (
        SELECT COUNT(*)
        FROM sports
        WHERE event_id = p_event_id
    ) > 0
    OR (
        SELECT COUNT(*)
        FROM concert
        WHERE event_id = p_event_id
    ) > 0 THEN
        RAISE EXCEPTION 'This event has already been assigned a subtype.';
    END IF;

    INSERT INTO theater (
        event_id,
        show_name,
        language
    )
    VALUES (
        p_event_id,
        p_show_name,
        p_language
    );

    RAISE NOTICE 'Theater details added successfully.';

END;
$$;

-- 20. Update Theater

CREATE OR REPLACE PROCEDURE update_theater(
    p_event_id INTEGER,
    p_show_name VARCHAR DEFAULT NULL,
    p_language VARCHAR DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF (
        SELECT COUNT(*)
        FROM theater
        WHERE event_id = p_event_id
    ) = 0 THEN
        RAISE EXCEPTION 'Theater does not exist.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
          AND status = 'Draft'
    ) = 0 THEN
        RAISE EXCEPTION 'Theater details can only be updated for Draft events.';
    END IF;

    UPDATE theater
    SET
        show_name = COALESCE(p_show_name, show_name),
        language = COALESCE(p_language, language)
    WHERE event_id = p_event_id;

    RAISE NOTICE 'Theater details updated successfully.';

END;
$$;

-- 21. Add Theater Genre

CREATE OR REPLACE PROCEDURE add_theater_genre(
    p_event_id INTEGER,
    p_genre VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF (
        SELECT COUNT(*)
        FROM theater
        WHERE event_id = p_event_id
    ) = 0 THEN
        RAISE EXCEPTION 'Theater does not exist.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
          AND status = 'Draft'
    ) = 0 THEN
        RAISE EXCEPTION 'Genres can only be added to Draft events.';
    END IF;

    INSERT INTO theater_genre (
        event_id,
        genre
    )
    VALUES (
        p_event_id,
        p_genre
    );

    RAISE NOTICE 'Theater genre added successfully.';

END;
$$;

-- 22. Remove Theater Genre

CREATE OR REPLACE PROCEDURE remove_theater_genre(
    p_event_id INTEGER,
    p_genre VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF (
        SELECT COUNT(*)
        FROM theater
        WHERE event_id = p_event_id
    ) = 0 THEN
        RAISE EXCEPTION 'Theater does not exist.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
          AND status = 'Draft'
    ) = 0 THEN
        RAISE EXCEPTION 'Genres can only be removed from Draft events.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM theater_genre
        WHERE event_id = p_event_id
          AND genre = p_genre
    ) = 0 THEN
        RAISE EXCEPTION 'Genre does not exist for this theater.';
    END IF;

    DELETE FROM theater_genre
    WHERE event_id = p_event_id
      AND genre = p_genre;

    RAISE NOTICE 'Theater genre removed successfully.';

END;
$$;

-- 23. Add Theater Director

CREATE OR REPLACE PROCEDURE add_theater_director(
    p_event_id INTEGER,
    p_director VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF (
        SELECT COUNT(*)
        FROM theater
        WHERE event_id = p_event_id
    ) = 0 THEN
        RAISE EXCEPTION 'Theater does not exist.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
          AND status = 'Draft'
    ) = 0 THEN
        RAISE EXCEPTION 'Directors can only be added to Draft events.';
    END IF;

    INSERT INTO theater_director (
        event_id,
        director
    )
    VALUES (
        p_event_id,
        p_director
    );

    RAISE NOTICE 'Director added successfully.';

END;
$$;

-- 24. Remove Theater Director

CREATE OR REPLACE PROCEDURE remove_theater_director(
    p_event_id INTEGER,
    p_director VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF (
        SELECT COUNT(*)
        FROM theater
        WHERE event_id = p_event_id
    ) = 0 THEN
        RAISE EXCEPTION 'Theater does not exist.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
          AND status = 'Draft'
    ) = 0 THEN
        RAISE EXCEPTION 'Directors can only be removed from Draft events.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM theater_director
        WHERE event_id = p_event_id
          AND director = p_director
    ) = 0 THEN
        RAISE EXCEPTION 'Director does not exist for this theater.';
    END IF;

    DELETE FROM theater_director
    WHERE event_id = p_event_id
      AND director = p_director;

    RAISE NOTICE 'Director removed successfully.';

END;
$$;

-- 25. Add Theater Writer

CREATE OR REPLACE PROCEDURE add_theater_writer(
    p_event_id INTEGER,
    p_writer VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF (
        SELECT COUNT(*)
        FROM theater
        WHERE event_id = p_event_id
    ) = 0 THEN
        RAISE EXCEPTION 'Theater does not exist.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
          AND status = 'Draft'
    ) = 0 THEN
        RAISE EXCEPTION 'Writers can only be added to Draft events.';
    END IF;

    INSERT INTO theater_writer (
        event_id,
        writer
    )
    VALUES (
        p_event_id,
        p_writer
    );

    RAISE NOTICE 'Writer added successfully.';

END;
$$;

-- 26. Remove Theater Writer

CREATE OR REPLACE PROCEDURE remove_theater_writer(
    p_event_id INTEGER,
    p_writer VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF (
        SELECT COUNT(*)
        FROM theater
        WHERE event_id = p_event_id
    ) = 0 THEN
        RAISE EXCEPTION 'Theater does not exist.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
          AND status = 'Draft'
    ) = 0 THEN
        RAISE EXCEPTION 'Writers can only be removed from Draft events.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM theater_writer
        WHERE event_id = p_event_id
          AND writer = p_writer
    ) = 0 THEN
        RAISE EXCEPTION 'Writer does not exist for this theater.';
    END IF;

    DELETE FROM theater_writer
    WHERE event_id = p_event_id
      AND writer = p_writer;

    RAISE NOTICE 'Writer removed successfully.';

END;
$$;

-- 27. Add Theater Cast Member

CREATE OR REPLACE PROCEDURE add_theater_cast(
    p_event_id INTEGER,
    p_cast_member VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF (
        SELECT COUNT(*)
        FROM theater
        WHERE event_id = p_event_id
    ) = 0 THEN
        RAISE EXCEPTION 'Theater does not exist.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
          AND status = 'Draft'
    ) = 0 THEN
        RAISE EXCEPTION 'Cast members can only be added to Draft events.';
    END IF;

    INSERT INTO theater_cast (
        event_id,
        cast_member
    )
    VALUES (
        p_event_id,
        p_cast_member
    );

    RAISE NOTICE 'Cast member added successfully.';

END;
$$;

-- 28. Remove Theater Cast Member

CREATE OR REPLACE PROCEDURE remove_theater_cast(
    p_event_id INTEGER,
    p_cast_member VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF (
        SELECT COUNT(*)
        FROM theater
        WHERE event_id = p_event_id
    ) = 0 THEN
        RAISE EXCEPTION 'Theater does not exist.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
          AND status = 'Draft'
    ) = 0 THEN
        RAISE EXCEPTION 'Cast members can only be removed from Draft events.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM theater_cast
        WHERE event_id = p_event_id
          AND cast_member = p_cast_member
    ) = 0 THEN
        RAISE EXCEPTION 'Cast member does not exist for this theater.';
    END IF;

    DELETE FROM theater_cast
    WHERE event_id = p_event_id
      AND cast_member = p_cast_member;

    RAISE NOTICE 'Cast member removed successfully.';

END;
$$;

-- 29. Process Refund Request

CREATE OR REPLACE PROCEDURE process_refund_request(
    p_refund_id INTEGER,
    p_refund_status VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_status VARCHAR;
    v_ticket_id INTEGER;
    v_user_id INTEGER;
    v_start_datetime TIMESTAMP;
BEGIN

    IF (
        SELECT COUNT(*)
        FROM refund
        WHERE refund_id = p_refund_id
    ) = 0 THEN
        RAISE EXCEPTION 'Refund request does not exist.';
    END IF;

    SELECT
        r.refund_status,
        ip.ticket_id,
        ip.user_id,
        e.start_datetime
    INTO
        v_current_status,
        v_ticket_id,
        v_user_id,
        v_start_datetime
    FROM refund r

    JOIN initial_payment ip
        ON r.transaction_id = ip.transaction_id

    JOIN ticket t
        ON ip.ticket_id = t.ticket_id

    JOIN event e
        ON t.event_id = e.event_id

    WHERE r.refund_id = p_refund_id;

    IF v_current_status <> 'Pending' THEN
        RAISE EXCEPTION
            'Only pending refund requests can be processed.';
    END IF;

    IF p_refund_status NOT IN (
        'Completed',
        'Rejected'
    ) THEN
        RAISE EXCEPTION
            'Refund status must be Completed or Rejected.';
    END IF;

    IF CURRENT_TIMESTAMP >= v_start_datetime THEN
        RAISE EXCEPTION
            'Refund requests cannot be processed after the event has started.';
    END IF;

    IF p_refund_status = 'Completed' THEN

        UPDATE refund
        SET refund_status = 'Completed'
        WHERE refund_id = p_refund_id;

        UPDATE ownership_history
        SET
            owned_until = CURRENT_TIMESTAMP,
            is_current = FALSE
        WHERE user_id = v_user_id
          AND ticket_id = v_ticket_id
          AND is_current = TRUE;

        UPDATE ticket
        SET status = 'Available'
        WHERE ticket_id = v_ticket_id;

    ELSE

        UPDATE refund
        SET refund_status = 'Rejected'
        WHERE refund_id = p_refund_id;

    END IF;

    RAISE NOTICE
        'Refund request processed successfully.';

END;
$$;