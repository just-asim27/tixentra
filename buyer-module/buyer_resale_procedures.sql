-- 1. List Ticket for Resale

CREATE OR REPLACE PROCEDURE list_ticket_for_resale(
    p_user_id INTEGER,
    p_ticket_id INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_event_id INTEGER;
    v_ticket_price NUMERIC;
    v_is_resale_allowed BOOLEAN;
    v_resale_profit_percentage NUMERIC;
    v_listed_price NUMERIC;
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
        t.price,
        t.event_id,
        e.is_resale_allowed,
        e.resale_profit_percentage
    INTO
        v_ticket_price,
        v_event_id,
        v_is_resale_allowed,
        v_resale_profit_percentage
    FROM ticket t
    JOIN event e
        ON t.event_id = e.event_id
    WHERE t.ticket_id = p_ticket_id;

    IF v_is_resale_allowed = FALSE THEN
        RAISE EXCEPTION 'Resale is not permitted for this event.';
    END IF;

    v_listed_price := v_ticket_price + (v_ticket_price * v_resale_profit_percentage / 100);

    IF (
        SELECT COUNT(*)
        FROM resale_listing_history
        WHERE user_id = p_user_id
          AND ticket_id = p_ticket_id
          AND status = 'Listed'
    ) > 0 THEN
        RAISE EXCEPTION 'This ticket is already listed for resale.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM resale_listing_history
        WHERE user_id = p_user_id
          AND ticket_id = p_ticket_id
    ) > 0 THEN

        UPDATE resale_listing_history
        SET
            listed_price = v_listed_price,
            status = 'Listed',
            listed_at = CURRENT_TIMESTAMP
        WHERE user_id = p_user_id
          AND ticket_id = p_ticket_id;

    ELSE

        INSERT INTO resale_listing_history (
            user_id,
            ticket_id,
            listed_price,
            status
        )
        VALUES (
            p_user_id,
            p_ticket_id,
            v_listed_price,
            'Listed'
        );

    END IF;

    RAISE NOTICE 'Ticket listed for resale successfully.';

END;
$$;

-- 2. Withdraw Resale Listing

CREATE OR REPLACE PROCEDURE withdraw_resale_listing(
    p_user_id INTEGER,
    p_ticket_id INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_status VARCHAR;
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

    SELECT status
    INTO v_status
    FROM resale_listing_history
    WHERE user_id = p_user_id
      AND ticket_id = p_ticket_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No resale listing found for this ticket.';
    END IF;

    IF v_status <> 'Listed' THEN
        RAISE EXCEPTION 'Only active listings can be withdrawn.';
    END IF;

    UPDATE resale_listing_history
    SET status = 'Withdrawn'
    WHERE user_id = p_user_id
      AND ticket_id = p_ticket_id;

    RAISE NOTICE 'Resale listing withdrawn successfully.';

END;
$$;

-- 3. Purchase Resale Ticket

CREATE OR REPLACE PROCEDURE purchase_resale_ticket(
    p_buyer_id INTEGER,
    p_ticket_id INTEGER,
    p_payment_method VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_seller_id INTEGER;
    v_listed_price NUMERIC;

    v_organization_id INTEGER;
    v_commission_percentage NUMERIC;

    v_organization_amount NUMERIC;
    v_seller_amount NUMERIC;

    v_transaction_id INTEGER;

    v_min_age INTEGER;
    v_buyer_dob DATE;
BEGIN

    IF (
        SELECT COUNT(*)
        FROM buyer
        WHERE user_id = p_buyer_id
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

    SELECT
        user_id,
        listed_price
    INTO
        v_seller_id,
        v_listed_price
    FROM resale_listing_history
    WHERE ticket_id = p_ticket_id
      AND status = 'Listed'
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Ticket is not currently listed for resale.';
    END IF;

    IF p_buyer_id = v_seller_id THEN
        RAISE EXCEPTION 'You cannot purchase your own listed ticket.';
    END IF;

    SELECT
        e.organization_id,
        e.org_commission_percentage,
        e.min_age
    INTO
        v_organization_id,
        v_commission_percentage,
        v_min_age
    FROM ticket t
    JOIN event e
        ON t.event_id = e.event_id
    WHERE t.ticket_id = p_ticket_id;

    IF v_min_age IS NOT NULL THEN

        SELECT dob
        INTO v_buyer_dob
        FROM buyer
        WHERE user_id = p_buyer_id;

        IF DATE_PART('year', AGE(CURRENT_DATE, v_buyer_dob)) < v_min_age THEN
            RAISE EXCEPTION
                'Buyer does not meet the minimum age requirement (%) for this event.',
                v_min_age;
        END IF;

    END IF;

    v_organization_amount := ROUND(
        v_listed_price * (v_commission_percentage / 100),
        2
    );

    v_seller_amount := v_listed_price - v_organization_amount;

    INSERT INTO transaction (
        amount,
        payment_method,
        payment_status
    )
    VALUES (
        v_listed_price,
        p_payment_method,
        'Completed'
    )
    RETURNING transaction_id
    INTO v_transaction_id;

    INSERT INTO resale_payment (
        transaction_id,
        organization_amount,
        seller_amount,
        organization_id,
        ticket_id,
        buyer_id,
        seller_id
    )
    VALUES (
        v_transaction_id,
        v_organization_amount,
        v_seller_amount,
        v_organization_id,
        p_ticket_id,
        p_buyer_id,
        v_seller_id
    );

    UPDATE ownership_history
    SET
        owned_until = CURRENT_TIMESTAMP,
        is_current = FALSE
    WHERE user_id = v_seller_id
      AND ticket_id = p_ticket_id
      AND is_current = TRUE;

    INSERT INTO ownership_history (
        user_id,
        ticket_id,
        owned_from,
        owned_until,
        is_current
    )
    VALUES (
        p_buyer_id,
        p_ticket_id,
        DEFAULT,
        NULL,
        TRUE
    );

    UPDATE resale_listing_history
    SET status = 'Sold'
    WHERE user_id = v_seller_id
      AND ticket_id = p_ticket_id;

    RAISE NOTICE 'Ticket purchased successfully via resale.';

END;
$$;

-- 4. Submit Buyer Review

CREATE OR REPLACE PROCEDURE submit_buyer_review(
    p_user_id INTEGER,
    p_event_id INTEGER,
    p_rating INTEGER,
    p_comment TEXT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
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
        FROM event
        WHERE event_id = p_event_id
    ) = 0 THEN
        RAISE EXCEPTION 'Event does not exist.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM event
        WHERE event_id = p_event_id
          AND status = 'Completed'
    ) = 0 THEN
        RAISE EXCEPTION 'Reviews can only be submitted for completed events.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM ownership_history oh
        JOIN ticket t
            ON oh.ticket_id = t.ticket_id
        WHERE oh.user_id = p_user_id
          AND t.event_id = p_event_id
    ) = 0 THEN
        RAISE EXCEPTION 'You can only review events you have attended.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM buyer_review
        WHERE user_id = p_user_id
          AND event_id = p_event_id
    ) > 0 THEN
        RAISE EXCEPTION 'You have already submitted a review for this event.';
    END IF;

    INSERT INTO buyer_review (
        rating,
        comment,
        user_id,
        event_id
    )
    VALUES (
        p_rating,
        p_comment,
        p_user_id,
        p_event_id
    );

    RAISE NOTICE 'Review submitted successfully.';

END;
$$;

-- 5. Update Buyer Review

CREATE OR REPLACE PROCEDURE update_buyer_review(
    p_user_id INTEGER,
    p_event_id INTEGER,
    p_rating INTEGER DEFAULT NULL,
    p_comment TEXT DEFAULT NULL
)
LANGUAGE plpgsql
AS $$
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
        FROM event
        WHERE event_id = p_event_id
    ) = 0 THEN
        RAISE EXCEPTION 'Event does not exist.';
    END IF;

    IF (
        SELECT COUNT(*)
        FROM buyer_review
        WHERE user_id = p_user_id
          AND event_id = p_event_id
    ) = 0 THEN
        RAISE EXCEPTION 'No review exists for this event.';
    END IF;

    UPDATE buyer_review
    SET
        rating = COALESCE(p_rating, rating),
        comment = COALESCE(p_comment, comment),
        revised_at = CURRENT_TIMESTAMP
    WHERE user_id = p_user_id
      AND event_id = p_event_id;

    RAISE NOTICE 'Review updated successfully.';

END;
$$;