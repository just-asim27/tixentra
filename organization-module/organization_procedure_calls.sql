-- 1. Organization Registrations 

CALL register_organization(
    p_name := 'Tech Events',
    p_email := 'info@techevents.com',
    p_phone := '0300-1234567',
    p_password := 'Password123',
    p_url := 'https://techevents.com',
    p_owner := 'Ali Khan',
    p_registration_no := '1234567',
    p_address := 'Lahore, Pakistan'
);

CALL register_organization(
    p_name := 'Prime Productions',
    p_email := 'contact@primeproductions.pk',
    p_phone := '0301-2345678',
    p_password := 'PrimePass456',
    p_url := 'https://primeproductions.pk',
    p_owner := 'Ahmed Raza',
    p_registration_no := '2345678',
    p_address := 'Islamabad, Pakistan'
);

CALL register_organization(
    p_name := 'Elite Entertainment',
    p_email := 'support@eliteentertainment.com',
    p_phone := '0302-3456789',
    p_password := 'Elite789',
    p_url := 'https://eliteentertainment.com',
    p_owner := 'Fatima Noor',
    p_registration_no := '3456789',
    p_address := 'Karachi, Pakistan'
);

CALL register_organization(
    p_name := 'Vision Events',
    p_email := 'hello@visionevents.pk',
    p_phone := '0303-4567890',
    p_password := 'Vision2026',
    p_url := NULL,
    p_owner := 'Usman Tariq',
    p_registration_no := '4567890',
    p_address := 'Faisalabad, Pakistan'
);

CALL register_organization(
    p_name := 'NextGen Conferences',
    p_email := 'admin@nextgenconf.org',
    p_phone := '0304-5678901',
    p_password := 'NextGen321',
    p_url := 'https://nextgenconf.org',
    p_owner := 'Sarah Khan',
    p_registration_no := '5678901',
    p_address := 'Rawalpindi, Pakistan'
);

SELECT * FROM organization;

-- 2.1. Required venue data for event creation calls

INSERT INTO venue (
    name,
    city,
    country,
    capacity,
    type,
    address
)
VALUES
(
    'National Stadium',
    'Karachi',
    'Pakistan',
    30,
    'Stadium',
    'Karachi, Pakistan'
),

(
    'Gaddafi Stadium',
    'Lahore',
    'Pakistan',
    60,
    'Stadium',
    'Lahore, Pakistan'
);

-- 2.2. Event Creations

CALL create_event(
    p_title := 'Pakistan vs India ODI',
    p_description := 'Asia Cup 2026 group stage match.',
    p_start_datetime := '2026-08-15 15:00:00',
    p_end_datetime := '2026-08-15 22:00:00',
    p_sale_start_datetime := '2026-07-20 00:00:00',
    p_sale_end_datetime := '2026-08-14 23:59:59',
    p_offered_payment := 50000.00,
    p_reservation_expiry_duration := 15,
    p_is_resale_allowed := TRUE,
    p_org_commission_percentage := 10.00,
    p_resale_profit_percentage := 5.00,
    p_max_reservations := 5,
    p_max_bookings := 4,
    p_min_age := NULL,
    p_base_price := 1500.00,
    p_increment_per_seat_type := 200.00,
    p_budget := 800000.00,
    p_is_refund_allowed := TRUE,
    p_organization_id := 1,
    p_venue_id := 1
);

CALL create_event(
    p_title := 'England vs Australia T20',
    p_description := 'International T20 series match.',
    p_start_datetime := '2026-08-25 18:00:00',
    p_end_datetime := '2026-08-25 22:30:00',
    p_sale_start_datetime := '2026-07-01 00:00:00',
    p_sale_end_datetime := '2026-08-24 23:59:59',
    p_offered_payment := 75000.00,
    p_reservation_expiry_duration := 10,
    p_is_resale_allowed := FALSE,
    p_org_commission_percentage := 0.00,
    p_resale_profit_percentage := 0.00,
    p_max_reservations := 8,
    p_max_bookings := 6,
    p_min_age := NULL,
    p_base_price := 2000.00,
    p_increment_per_seat_type := 500.00,
    p_budget := 1500000.00,
    p_is_refund_allowed := FALSE,
    p_organization_id := 2,
    p_venue_id := 2
);

-- 2.3. Create Sports Details

CALL create_sports(
    p_event_id := 1,
    p_sport_type := 'Cricket',
    p_home_team := 'Pakistan',
    p_away_team := 'India',
    p_competition_name := 'Asia Cup 2026'
);

CALL create_sports(
    p_event_id := 2,
    p_sport_type := 'Cricket',
    p_home_team := 'England',
    p_away_team := 'Australia',
    p_competition_name := 'World T20 Series'
);

SELECT * FROM event;
SELECT * FROM sports;

-- 3. Update Event

CALL update_event(
    p_event_id := 1,
    p_title := 'Pakistan vs India ODI - Updated',
    p_description := 'Asia Cup 2026 group stage match with updated event information.',
    p_offered_payment := 60000.00,
    p_max_reservations := 6,
    p_max_bookings := 5,
    p_base_price := 1800.00,
    p_budget := 900000.00
);

CALL update_sports(
    p_event_id := 1,
    p_competition_name := 'Asia Cup 2026 - Final'
);

SELECT * FROM event WHERE event_id = 1;
SELECT * FROM sports WHERE event_id = 1;

-- 4. Publish Event

CALL publish_event(
    p_event_id := 1
);

SELECT * FROM event WHERE event_id = 1;

-- 5. Approve Organizer

CALL approve_organizer(
    p_user_id := 2,
    p_event_id := 1
);

SELECT * FROM event WHERE event_id = 1;

-- 6.1. Seat Data Required for Schedule Event

DO $$
DECLARE
    v_row INT;
    v_seat INT;

    v_row_letter CHAR;
    v_seat_type VARCHAR;
    v_section VARCHAR;

BEGIN

    FOR v_row IN 1..5 LOOP

        v_row_letter := CHR(64 + v_row);

        IF v_row <= 2 THEN
            v_seat_type := 'VIP';
            v_section := 'Front';
        ELSIF v_row <= 4 THEN
            v_seat_type := 'Premium';
            v_section := 'Middle';
        ELSE
            v_seat_type := 'Regular';
            v_section := 'Rear';
        END IF;

        FOR v_seat IN 1..6 LOOP

            INSERT INTO seat (
                row,
                number,
                section,
                seat_type,
                venue_id
            )
            VALUES (
                v_row_letter,
                v_seat,
                v_section,
                v_seat_type,
                1
            );

        END LOOP;

    END LOOP;

    FOR v_row IN 1..10 LOOP

        v_row_letter := CHR(64 + v_row);

        IF v_row <= 3 THEN
            v_seat_type := 'VIP';
            v_section := 'Front';
        ELSIF v_row <= 6 THEN
            v_seat_type := 'Premium';
            v_section := 'Middle';
        ELSE
            v_seat_type := 'Regular';
            v_section := 'Rear';
        END IF;

        FOR v_seat IN 1..6 LOOP

            INSERT INTO seat (
                row,
                number,
                section,
                seat_type,
                venue_id
            )
            VALUES (
                v_row_letter,
                v_seat,
                v_section,
                v_seat_type,
                2
            );

        END LOOP;

    END LOOP;

END;
$$;

-- 6.2. Schedule Event

CALL schedule_event(1);

SELECT * FROM event WHERE event_id = 1;

-- 29.1. Process Refund Requests

CALL process_refund_request(
    p_refund_id := 1,
    p_refund_status := 'Completed'
);

SELECT *
FROM refund
WHERE refund_id = 1;

SELECT *
FROM ownership_history
WHERE ticket_id = 1;

SELECT *
FROM ticket
WHERE ticket_id = 1;

-- 7.1. Required update before start event

UPDATE event
SET
    sale_start_datetime = CURRENT_TIMESTAMP - INTERVAL '3 days',
    sale_end_datetime   = CURRENT_TIMESTAMP - INTERVAL '2 hours',
    start_datetime      = CURRENT_TIMESTAMP - INTERVAL '1 hour',
    end_datetime        = CURRENT_TIMESTAMP + INTERVAL '3 hours'
WHERE event_id = 1;

-- 7.2. Start Event

CALL start_event(1);

SELECT * FROM event WHERE event_id = 1;

-- 8.1. Required update before complete event

UPDATE event
SET end_datetime = CURRENT_TIMESTAMP - INTERVAL '10 minutes'
WHERE event_id = 1;

-- 8.2. Complete Event

CALL complete_event(1);

SELECT * FROM event WHERE event_id = 1;

-- 9. Cancel Event

CALL publish_event(2);
CALL approve_organizer(2, 2);
CALL schedule_event(2);
CALL cancel_event(2);

SELECT * FROM event WHERE event_id = 2;

-- 10. Issue Event Payment

CALL issue_event_payment(
    1,
    'Bank Transfer',
    5,
    'Excellent event management and communication throughout the event.'
);

SELECT t.*
FROM transaction t
JOIN event_payment ep
    ON t.transaction_id = ep.transaction_id
WHERE ep.event_id = 1;

SELECT *
FROM event_payment
WHERE event_id = 1;

SELECT *
FROM organization_review
WHERE event_id = 1;

-- 11. Update Organization Review

CALL update_organizer_review(
    p_event_id := 1,
    p_rating := 4
);

SELECT *
FROM organization_review
WHERE event_id = 1;