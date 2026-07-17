-- 1. Organizer Table

CREATE TABLE organizer (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    national_id VARCHAR(15) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    dob DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    phone VARCHAR(12) NOT NULL UNIQUE,

    CHECK (dob < CURRENT_DATE),
    CHECK (TRIM(name) != ''),
    CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CHECK (TRIM(password) != ''),
    CHECK (national_id ~ '^[1-8]\d{4}-\d{7}-\d{1}$'),
    CHECK (phone ~ '^03\d{2}-\d{7}$')
);

-- 2. Buyer Table

CREATE TABLE buyer (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    national_id VARCHAR(15) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    dob DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    phone VARCHAR(12) NOT NULL UNIQUE,

    CHECK (dob < CURRENT_DATE),
    CHECK (TRIM(name) != ''),
    CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CHECK (TRIM(password) != ''),
    CHECK (national_id ~ '^[1-8]\d{4}-\d{7}-\d{1}$'),
    CHECK (phone ~ '^03\d{2}-\d{7}$')
);

-- 3. Organization Table

CREATE TABLE organization (
    organization_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    owner VARCHAR(100) NOT NULL,
    registration_no VARCHAR(50) NOT NULL UNIQUE,
    address VARCHAR(255) NOT NULL,

    CHECK (TRIM(name) != ''),
    CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CHECK (phone ~ '^03\d{2}-\d{7}$'),
    CHECK (TRIM(password) != ''),
    CHECK (url IS NULL OR url ~ '^https?://[A-Za-z0-9.-]+\.[A-Za-z]{2,}(/\S*)?$'),
    CHECK (TRIM(owner) != ''),
    CHECK (registration_no ~ '^\d{7}$'),
    CHECK (TRIM(address) != '')
);

-- 4. Venue Table

CREATE TABLE venue (
    venue_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    capacity INTEGER NOT NULL,
    type VARCHAR(50) NOT NULL,
    address VARCHAR(255) NOT NULL,

    CHECK (TRIM(name) != ''),
    CHECK (TRIM(city) != ''),
    CHECK (TRIM(country) != ''),
    CHECK (capacity > 0),
    CHECK (
        TRIM(type) IN (
            'Conference Hall',
            'Auditorium',
            'Banquet Hall',
            'Stadium',
            'Open Ground',
            'Exhibition Center',
            'Hotel Ballroom',
            'Indoor Sports Arena'
        )
    ),
    CHECK (TRIM(address) != '')
);

-- 5. Seat Table 

CREATE TABLE seat (
    seat_id SERIAL PRIMARY KEY,
    row VARCHAR(10) NOT NULL,
    number INTEGER NOT NULL,
    section VARCHAR(50) NOT NULL,
    seat_type VARCHAR(50) NOT NULL,
    venue_id INTEGER NOT NULL,

    CHECK (TRIM(row) != ''),
    CHECK (number > 0),
    CHECK (TRIM(section) != ''),
    CHECK (
        TRIM(seat_type) IN (
            'Regular',
            'Premium',
            'VIP'
        )
    ),
    
    FOREIGN KEY (venue_id) REFERENCES venue(venue_id),

    UNIQUE (venue_id, row, number)   -- Prevents duplicate seat rows for the same physical seat.
);

-- 6. Event Table

CREATE TABLE event (
    event_id SERIAL PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    
    start_datetime TIMESTAMP NOT NULL,
    end_datetime TIMESTAMP NOT NULL,
    
    sale_start_datetime TIMESTAMP NOT NULL,
    sale_end_datetime TIMESTAMP NOT NULL,
    
    offered_payment NUMERIC(12,2) NOT NULL,
    
    status VARCHAR(50) NOT NULL,
    
    reservation_expiry_duration INTEGER NOT NULL,
    
    is_resale_allowed BOOLEAN NOT NULL,
    
    org_commission_percentage NUMERIC(5,2) NOT NULL,
    resale_profit_percentage NUMERIC(5,2) NOT NULL,
    
    max_reservations INTEGER NOT NULL,
    max_bookings INTEGER NOT NULL,
    
    min_age INTEGER,
    
    base_price NUMERIC(12,2) NOT NULL,
    increment_per_seat_type NUMERIC(12,2) NOT NULL,
    
    budget NUMERIC(12,2) NOT NULL,
    
    organization_id INTEGER NOT NULL,
    venue_id INTEGER NOT NULL,
    user_id INTEGER,

    FOREIGN KEY (organization_id) REFERENCES organization(organization_id),
    FOREIGN KEY (venue_id) REFERENCES venue(venue_id),
    FOREIGN KEY (user_id) REFERENCES organizer(user_id),

    CHECK (TRIM(title) != ''),

    CHECK (end_datetime > start_datetime),

    CHECK (sale_start_datetime < sale_end_datetime),
    CHECK (sale_end_datetime <= start_datetime),

    CHECK (offered_payment > 0),

    CHECK (reservation_expiry_duration > 0),

    CHECK (org_commission_percentage BETWEEN 0 AND 100),
    CHECK (resale_profit_percentage BETWEEN 0 AND 100),

    CHECK (max_reservations > 0),
    CHECK (max_bookings > 0),

    CHECK (
        min_age IS NULL OR
        min_age IN (13, 16, 18, 21)
    ),

    CHECK (base_price > 0),
    CHECK (increment_per_seat_type > 0),

    CHECK (budget > 0),

    CHECK (
        TRIM(status) IN (
            'Draft',
            'Application_Open',
            'Application_Closed',
            'Scheduled',
            'Active',
            'Completed',
            'Cancelled'
        )
    ),

    CHECK (description IS NULL OR TRIM(description) != ''),

    CHECK (
        is_resale_allowed = TRUE
        OR
        (
            is_resale_allowed = FALSE
            AND org_commission_percentage = 0
            AND resale_profit_percentage = 0
        )
    )

);

-- 7. Theater Table 

CREATE TABLE theater (
    event_id INTEGER PRIMARY KEY,
    show_name VARCHAR(150) NOT NULL,
    language VARCHAR(50) NOT NULL,

    FOREIGN KEY (event_id) REFERENCES event(event_id),

    CHECK (TRIM(show_name) != ''),

    CHECK (
        TRIM(language) IN (
            'English',
            'Urdu',
            'Hindi',
            'Punjabi',
            'Other'
        )
    )
);

-- 8. Theater Genre Table

CREATE TABLE theater_genre (
    event_id INTEGER,
    genre VARCHAR(50),

    PRIMARY KEY (event_id, genre),

    FOREIGN KEY (event_id) REFERENCES theater(event_id),

    CHECK (TRIM(genre) IN (
        'Drama',
        'Comedy',
        'Tragedy',
        'Musical',
        'Romance',
        'Historical',
        'Thriller'
    ))
);

-- 9. Theater Director Table

CREATE TABLE theater_director (
    event_id INTEGER,
    director VARCHAR(100),

    PRIMARY KEY (event_id, director),

    FOREIGN KEY (event_id) REFERENCES theater(event_id),

    CHECK (TRIM(director) != '')
);

-- 10. Theater Writer Table

CREATE TABLE theater_writer (
    event_id INTEGER,
    writer VARCHAR(100),

    PRIMARY KEY (event_id, writer),

    FOREIGN KEY (event_id) REFERENCES theater(event_id),

    CHECK (TRIM(writer) != '')
);

-- 11. Theater Cast Table

CREATE TABLE theater_cast (
    event_id INTEGER,
    cast_member VARCHAR(100),

    PRIMARY KEY (event_id, cast_member),

    FOREIGN KEY (event_id) REFERENCES theater(event_id),

    CHECK (TRIM(cast_member) != '')
);

-- 12. Sports Table

CREATE TABLE sports (
    event_id INTEGER PRIMARY KEY,
    sport_type VARCHAR(50) NOT NULL,
    home_team VARCHAR(100) NOT NULL,
    away_team VARCHAR(100) NOT NULL,
    competition_name VARCHAR(150) NOT NULL,

    FOREIGN KEY (event_id) REFERENCES event(event_id),

    CHECK (TRIM(sport_type) IN (
        'Football',
        'Cricket',
        'Basketball',
        'Tennis',
        'Hockey',
        'Volleyball',
        'Other'
    )),

    CHECK (TRIM(home_team) != ''),
    CHECK (TRIM(away_team) != ''),
    CHECK (TRIM(competition_name) != ''),

    CHECK (home_team != away_team)
);

-- 13. Concert Table 

CREATE TABLE concert (
    event_id INTEGER PRIMARY KEY,

    FOREIGN KEY (event_id) REFERENCES event(event_id)
);

-- 14. Concert Artist Table

CREATE TABLE concert_artist (
    event_id INTEGER,
    artist_name VARCHAR(100),

    PRIMARY KEY (event_id, artist_name),

    FOREIGN KEY (event_id) REFERENCES concert(event_id),

    CHECK (TRIM(artist_name) != '')
);

-- 15. Concert Genre Table 

CREATE TABLE concert_genre (
    event_id INTEGER,
    genre VARCHAR(50),

    PRIMARY KEY (event_id, genre),

    FOREIGN KEY (event_id) REFERENCES concert(event_id),

    CHECK (
        TRIM(genre) IN (
            'Pop',
            'Rock',
            'Jazz',
            'Classical',
            'Hip Hop',
            'Electronic',
            'Folk',
            'Other'
        )
    )
);

-- 16. Ticket Table

CREATE TABLE ticket (
    ticket_id SERIAL PRIMARY KEY,
    price NUMERIC(12,2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    event_id INTEGER NOT NULL,
    seat_id INTEGER NOT NULL,

    FOREIGN KEY (event_id) REFERENCES event(event_id),
    FOREIGN KEY (seat_id) REFERENCES seat(seat_id),

    CHECK (price > 0),

    CHECK (
        TRIM(status) IN (
            'Available',
            'Reserved',
            'Sold'
        )
    ),

    UNIQUE (event_id, seat_id)   -- Prevents the same seat being ticketed twice for the same event.
);

-- 17. Transaction Table

CREATE TABLE transaction (
    transaction_id SERIAL PRIMARY KEY,
    amount NUMERIC(12,2) NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    date_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_status VARCHAR(50) NOT NULL,

    CHECK (amount > 0),

    CHECK (
        TRIM(payment_method) IN (
            'Card',
            'Bank Transfer',
            'Easypaisa',
            'JazzCash'
        )
    ),

    CHECK (
        TRIM(payment_status) IN (
            'Pending',
            'Completed',
            'Failed'
        )
    )
);

-- 18. Resale Payment Table

CREATE TABLE resale_payment (
    transaction_id INTEGER PRIMARY KEY,
    organization_amount NUMERIC(12,2) NOT NULL,
    seller_amount NUMERIC(12,2) NOT NULL,

    organization_id INTEGER NOT NULL,
    ticket_id INTEGER NOT NULL,

    buyer_id INTEGER NOT NULL,
    seller_id INTEGER NOT NULL,

    FOREIGN KEY (transaction_id)
        REFERENCES transaction(transaction_id),

    FOREIGN KEY (organization_id)
        REFERENCES organization(organization_id),

    FOREIGN KEY (ticket_id)
        REFERENCES ticket(ticket_id),

    FOREIGN KEY (buyer_id)
        REFERENCES buyer(user_id),

    FOREIGN KEY (seller_id)
        REFERENCES buyer(user_id),

    CHECK (organization_amount > 0),
    CHECK (seller_amount > 0),
    CHECK (buyer_id != seller_id)    
);

-- 19. Initial Payment Table

CREATE TABLE initial_payment (
    transaction_id INTEGER PRIMARY KEY,

    organization_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    ticket_id INTEGER NOT NULL,

    FOREIGN KEY (transaction_id)
        REFERENCES transaction(transaction_id),

    FOREIGN KEY (organization_id)
        REFERENCES organization(organization_id),

    FOREIGN KEY (user_id)
        REFERENCES buyer(user_id),

    FOREIGN KEY (ticket_id)
        REFERENCES ticket(ticket_id)
);

-- 20. Event Payment Table

CREATE TABLE event_payment (
    transaction_id INTEGER PRIMARY KEY,

    user_id INTEGER NOT NULL,
    event_id INTEGER NOT NULL,
    organization_id INTEGER NOT NULL,

    FOREIGN KEY (transaction_id)
        REFERENCES transaction(transaction_id),

    FOREIGN KEY (user_id)
        REFERENCES organizer(user_id),

    FOREIGN KEY (event_id)
        REFERENCES event(event_id),

    FOREIGN KEY (organization_id)
        REFERENCES organization(organization_id)
);

-- 21. Refund Table

CREATE TABLE refund (
    refund_id SERIAL PRIMARY KEY,
    amount NUMERIC(12,2) NOT NULL,
    refund_method VARCHAR(50) NOT NULL,
    refund_status VARCHAR(50) NOT NULL,
    reason TEXT NOT NULL,
    date_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    transaction_id INTEGER NOT NULL,

    FOREIGN KEY (transaction_id)
        REFERENCES transaction(transaction_id),

    CHECK (amount > 0),

    CHECK (
        TRIM(refund_method) IN (
            'Card',
            'Bank Transfer',
            'Easypaisa',
            'JazzCash'
        )
    ),

    CHECK (
        TRIM(refund_status) IN (
            'Pending',
            'Completed',
            'Failed',
            'Rejected'
        )
    ),

    CHECK (TRIM(reason) != '')
);

-- 22. Buyer Review Table

CREATE TABLE buyer_review (
    review_id SERIAL PRIMARY KEY,
    rating INTEGER NOT NULL,
    comment TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    revised_at TIMESTAMP,
    user_id INTEGER NOT NULL,
    event_id INTEGER NOT NULL,

    FOREIGN KEY (user_id)
        REFERENCES buyer(user_id),

    FOREIGN KEY (event_id)
        REFERENCES event(event_id),

    CHECK (rating >= 1 AND rating <= 5),

    CHECK (
        comment IS NULL
        OR TRIM(comment) != ''
    ),

    CHECK (
        revised_at IS NULL
        OR revised_at >= created_at
    ),

    UNIQUE (user_id, event_id)   -- One review per buyer per event.    
);

-- 23. Organization Review Table

CREATE TABLE organization_review (
    review_id SERIAL PRIMARY KEY,
    rating INTEGER NOT NULL,
    comment TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    revised_at TIMESTAMP,
    user_id INTEGER NOT NULL,
    event_id INTEGER NOT NULL,
    organization_id INTEGER NOT NULL,

    FOREIGN KEY (user_id)
        REFERENCES organizer(user_id),

    FOREIGN KEY (event_id)
        REFERENCES event(event_id),

    FOREIGN KEY (organization_id)
        REFERENCES organization(organization_id),

    CHECK (rating >= 1 AND rating <= 5),

    CHECK (
        comment IS NULL
        OR TRIM(comment) != ''
    ),

    CHECK (
        revised_at IS NULL
        OR revised_at >= created_at
    ), 

    UNIQUE (user_id, event_id, organization_id)  -- One review per organizer per event per organization.     
);

-- 24. Reservation History Table

CREATE TABLE reservation_history (
    user_id INTEGER NOT NULL,
    ticket_id INTEGER NOT NULL,
    reservation_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expiry_datetime TIMESTAMP NOT NULL,
    status VARCHAR(50) NOT NULL,

    PRIMARY KEY (user_id, ticket_id),

    FOREIGN KEY (user_id)
        REFERENCES buyer(user_id),

    FOREIGN KEY (ticket_id)
        REFERENCES ticket(ticket_id),

    CHECK (expiry_datetime > reservation_datetime),

    CHECK (
        TRIM(status) IN (
            'Active',
            'Converted',
            'Expired'
        )
    )    
);

-- 25. Ownership History Table

CREATE TABLE ownership_history (
    user_id INTEGER NOT NULL,
    ticket_id INTEGER NOT NULL,
    owned_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    owned_until TIMESTAMP,
    is_current BOOLEAN NOT NULL,

    PRIMARY KEY (user_id, ticket_id),

    FOREIGN KEY (user_id)
        REFERENCES buyer(user_id),

    FOREIGN KEY (ticket_id)
        REFERENCES ticket(ticket_id),

    CHECK (
        owned_until IS NULL
        OR owned_until > owned_from
    ),

    CHECK (
        (is_current = TRUE  AND owned_until IS NULL)
        OR
        (is_current = FALSE AND owned_until IS NOT NULL)
    )    
);

-- 26. Resale Listing History Table

CREATE TABLE resale_listing_history (
    user_id INTEGER NOT NULL,
    ticket_id INTEGER NOT NULL,
    listed_price NUMERIC(12,2) NOT NULL,
    status VARCHAR(50) NOT NULL,
    listed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (user_id, ticket_id),

    FOREIGN KEY (user_id)
        REFERENCES buyer(user_id),

    FOREIGN KEY (ticket_id)
        REFERENCES ticket(ticket_id),

    CHECK (listed_price > 0),

    CHECK (
        TRIM(status) IN (
            'Listed',
            'Sold',
            'Withdrawn'
        )
    )    
);

-- 27. Application History Table 

CREATE TABLE application_history (
    user_id INTEGER NOT NULL,
    event_id INTEGER NOT NULL,
    applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) NOT NULL,

    PRIMARY KEY (user_id, event_id),

    FOREIGN KEY (user_id)
        REFERENCES organizer(user_id),

    FOREIGN KEY (event_id)
        REFERENCES event(event_id),

    CHECK (
        TRIM(status) IN (
            'Pending',
            'Accepted',
            'Rejected'
        )
    )    
);