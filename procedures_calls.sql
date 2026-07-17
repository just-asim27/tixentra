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
    'Expo Convention Hall',
    'Lahore',
    'Pakistan',
    30,                     -- 5 rows × 6 seats
    'Conference Hall',
    'Johar Town, Lahore'
),

(
    'National Stadium Ground',
    'Karachi',
    'Pakistan',
    60,                     -- 10 rows × 6 seats
    'Stadium',
    'Karsaz Road, Karachi'
),

(
    'Arts & Culture Auditorium',
    'Islamabad',
    'Pakistan',
    24,                     -- 4 rows × 6 seats
    'Auditorium',
    'F-6 Markaz, Islamabad'
),

(
    'Business Expo Center',
    'Faisalabad',
    'Pakistan',
    48,                     -- 6 rows × 8 seats
    'Exhibition Center',
    'Susan Road, Faisalabad'
),

(
    'Pearl Continental Ballroom',
    'Rawalpindi',
    'Pakistan',
    20,                     -- 4 rows × 5 seats
    'Hotel Ballroom',
    'Mall Road, Rawalpindi'
);

-- 2.2. Event Creations

CALL create_event(
    p_title := 'Tech Innovators Summit 2026',
    p_description := 'A gathering of leading tech innovators, startups, and investors to discuss emerging trends in AI and software.',
    p_start_datetime := '2026-08-15 09:00:00',
    p_end_datetime := '2026-08-15 18:00:00',
    p_sale_start_datetime := '2026-07-20 00:00:00',
    p_sale_end_datetime := '2026-08-14 23:59:59',
    p_offered_payment := 50000.00,
    p_reservation_expiry_duration := 15,
    p_is_resale_allowed := TRUE,
    p_org_commission_percentage := 10.00,
    p_resale_profit_percentage := 5.00,
    p_max_reservations := 5,
    p_max_bookings := 4,
    p_min_age := 18,
    p_base_price := 1500.00,
    p_increment_per_seat_type := 200.00,
    p_budget := 800000.00,
    p_organization_id := 1,
    p_venue_id := 1
);

CALL create_event(
    p_title := 'Prime Music Festival',
    p_description := 'An open-air music festival featuring top local and international artists across multiple genres.',
    p_start_datetime := '2026-08-25 16:00:00',
    p_end_datetime := '2026-08-25 23:30:00',
    p_sale_start_datetime := '2026-08-01 00:00:00',
    p_sale_end_datetime := '2026-08-24 23:59:59',
    p_offered_payment := 75000.00,
    p_reservation_expiry_duration := 10,
    p_is_resale_allowed := FALSE,
    p_org_commission_percentage := 0.00,
    p_resale_profit_percentage := 0.00,
    p_max_reservations := 8,
    p_max_bookings := 6,
    p_min_age := 16,
    p_base_price := 2000.00,
    p_increment_per_seat_type := 500.00,
    p_budget := 1500000.00,
    p_organization_id := 2,
    p_venue_id := 2
);

CALL create_event(
    p_title := 'Elite Comedy Night',
    p_description := 'An evening of stand-up comedy featuring some of the funniest comedians from across the country.',
    p_start_datetime := '2026-09-05 20:00:00',
    p_end_datetime := '2026-09-05 23:00:00',
    p_sale_start_datetime := '2026-08-10 00:00:00',
    p_sale_end_datetime := '2026-09-04 23:59:59',
    p_offered_payment := 30000.00,
    p_reservation_expiry_duration := 20,
    p_is_resale_allowed := TRUE,
    p_org_commission_percentage := 8.00,
    p_resale_profit_percentage := 3.00,
    p_max_reservations := 4,
    p_max_bookings := 3,
    p_min_age := 16,
    p_base_price := 1000.00,
    p_increment_per_seat_type := 150.00,
    p_budget := 400000.00,
    p_organization_id := 3,
    p_venue_id := 3
);

CALL create_event(
    p_title := 'Vision Business Expo',
    p_description := 'A large-scale expo connecting entrepreneurs, investors, and industry leaders for networking and growth opportunities.',
    p_start_datetime := '2026-09-15 10:00:00',
    p_end_datetime := '2026-09-17 17:00:00',
    p_sale_start_datetime := '2026-08-20 00:00:00',
    p_sale_end_datetime := '2026-09-14 23:59:59',
    p_offered_payment := 25000.00,
    p_reservation_expiry_duration := 30,
    p_is_resale_allowed := FALSE,
    p_org_commission_percentage := 0.00,
    p_resale_profit_percentage := 0.00,
    p_max_reservations := 6,
    p_max_bookings := 5,
    p_min_age := 18,
    p_base_price := 3000.00,
    p_increment_per_seat_type := 300.00,
    p_budget := 1200000.00,
    p_organization_id := 4,
    p_venue_id := 4
);

CALL create_event(
    p_title := 'NextGen Leadership Conference',
    p_description := 'A conference focused on developing leadership skills among young professionals through workshops and keynote sessions.',
    p_start_datetime := '2026-09-30 09:00:00',
    p_end_datetime := '2026-10-01 16:00:00',
    p_sale_start_datetime := '2026-09-01 00:00:00',
    p_sale_end_datetime := '2026-09-29 23:59:59',
    p_offered_payment := 20000.00,
    p_reservation_expiry_duration := 25,
    p_is_resale_allowed := TRUE,
    p_org_commission_percentage := 9.00,
    p_resale_profit_percentage := 4.00,
    p_max_reservations := 3,
    p_max_bookings := 2,
    p_min_age := 16,
    p_base_price := 1800.00,
    p_increment_per_seat_type := 250.00,
    p_budget := 600000.00,
    p_organization_id := 5,
    p_venue_id := 5
);

-- 3. Update Event

CALL update_event(
    p_event_id := 1,
    p_title := 'Tech Innovators Summit 2026 - Updated',
    p_description := 'An updated description featuring AI, cybersecurity, cloud computing, and software engineering.',
    p_offered_payment := 60000.00,
    p_max_reservations := 6,
    p_max_bookings := 5,
    p_base_price := 1800.00,
    p_budget := 900000.00
);

-- 4. Publish Event

CALL publish_event(
    p_event_id := 1
);

-- 5. Approve Organizer

CALL approve_organizer(
    p_user_id := 2,
    p_event_id := 1
);

-- 6.1. Seat data required for schedule event

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

    FOR v_row IN 1..4 LOOP

        v_row_letter := CHR(64 + v_row);

        IF v_row = 1 THEN
            v_seat_type := 'VIP';
            v_section := 'Front';
        ELSIF v_row = 2 THEN
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
                3
            );
        END LOOP;

    END LOOP;

    FOR v_row IN 1..6 LOOP

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

        FOR v_seat IN 1..8 LOOP
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
                4
            );
        END LOOP;

    END LOOP;

    FOR v_row IN 1..4 LOOP

        v_row_letter := CHR(64 + v_row);

        IF v_row = 1 THEN
            v_seat_type := 'VIP';
            v_section := 'Front';
        ELSIF v_row = 2 THEN
            v_seat_type := 'Premium';
            v_section := 'Middle';
        ELSE
            v_seat_type := 'Regular';
            v_section := 'Rear';
        END IF;

        FOR v_seat IN 1..5 LOOP
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
                5
            );
        END LOOP;

    END LOOP;

END;
$$;

-- 6.2. Schedule Event

CALL schedule_event(1);

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

-- 8.1. Required update before complete event

UPDATE event
SET end_datetime = CURRENT_TIMESTAMP - INTERVAL '10 minutes'
WHERE event_id = 1;

-- 8.2. Complete Event

CALL complete_event(1);

-- 9. Cancel Event

CALL publish_event(2);
CALL approve_organizer(2, 2);
CALL schedule_event(2);
CALL cancel_event(2);

-- 10. Issue Event Payment

CALL issue_event_payment(
    1,
    'Bank Transfer'
);