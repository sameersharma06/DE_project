CREATE SCHEMA IF NOT EXISTS gmaps;
SET search_path TO gmaps;

CREATE TABLE cities (
    city_id INT PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL,
    center_lat NUMERIC(9,6) NOT NULL,
    center_lng NUMERIC(9,6) NOT NULL,
    CHECK (center_lat BETWEEN -90 AND 90),
    CHECK (center_lng BETWEEN -180 AND 180)
);

CREATE TABLE place_categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
);

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    display_name VARCHAR(150) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    home_city_id INT REFERENCES cities(city_id),
    is_local_guide BOOLEAN NOT NULL,
    guide_level SMALLINT CHECK (guide_level BETWEEN 1 AND 10),
    created_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE places (
    place_id INT PRIMARY KEY,
    plus_code VARCHAR(30) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    category_id INT NOT NULL REFERENCES place_categories(category_id),
    city_id INT NOT NULL REFERENCES cities(city_id),
    latitude NUMERIC(9,6) NOT NULL CHECK (latitude BETWEEN -90 AND 90),
    longitude NUMERIC(9,6) NOT NULL CHECK (longitude BETWEEN -180 AND 180),
    address TEXT NOT NULL,
    phone VARCHAR(30),
    website TEXT,
    price_level SMALLINT CHECK (price_level BETWEEN 1 AND 4),
    avg_rating NUMERIC(2,1) CHECK (avg_rating BETWEEN 1 AND 5),
    review_count INT NOT NULL CHECK (review_count >= 0),
    is_permanently_closed BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE opening_hours (
    place_id INT NOT NULL REFERENCES places(place_id),
    weekday SMALLINT NOT NULL CHECK (weekday BETWEEN 1 AND 7),
    opens TIME NOT NULL,
    closes TIME NOT NULL,
    PRIMARY KEY (place_id, weekday)
);

CREATE TABLE place_reviews (
    review_id INT PRIMARY KEY,
    place_id INT NOT NULL REFERENCES places(place_id),
    user_id INT NOT NULL REFERENCES users(user_id),
    rating NUMERIC(2,1) NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    photo_count SMALLINT NOT NULL CHECK (photo_count >= 0),
    created_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE saved_places (
    user_id INT NOT NULL REFERENCES users(user_id),
    place_id INT NOT NULL REFERENCES places(place_id),
    list_name VARCHAR(100) NOT NULL,
    saved_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (user_id, place_id, list_name)
);

CREATE TABLE road_segments (
    segment_id INT PRIMARY KEY,
    road_name VARCHAR(255) NOT NULL,
    city_id INT NOT NULL REFERENCES cities(city_id),
    road_type VARCHAR(100) NOT NULL,
    start_lat NUMERIC(9,6) NOT NULL CHECK (start_lat BETWEEN -90 AND 90),
    start_lng NUMERIC(9,6) NOT NULL CHECK (start_lng BETWEEN -180 AND 180),
    end_lat NUMERIC(9,6) NOT NULL CHECK (end_lat BETWEEN -90 AND 90),
    end_lng NUMERIC(9,6) NOT NULL CHECK (end_lng BETWEEN -180 AND 180),
    length_m INT NOT NULL CHECK (length_m > 0),
    speed_limit_kmph SMALLINT NOT NULL CHECK (speed_limit_kmph > 0)
);

CREATE TABLE traffic_readings (
    reading_id BIGINT PRIMARY KEY,
    segment_id INT NOT NULL REFERENCES road_segments(segment_id),
    recorded_at TIMESTAMPTZ NOT NULL,
    avg_speed_kmph NUMERIC(5,2) NOT NULL CHECK (avg_speed_kmph >= 0),
    congestion_level VARCHAR(20) NOT NULL
        CHECK (congestion_level IN ('LOW', 'MODERATE', 'HEAVY'))
);

CREATE TABLE navigation_sessions (
    session_id BIGINT PRIMARY KEY,
    user_id INT REFERENCES users(user_id),
    origin_place_id INT REFERENCES places(place_id),
    origin_lat NUMERIC(9,6) NOT NULL CHECK (origin_lat BETWEEN -90 AND 90),
    origin_lng NUMERIC(9,6) NOT NULL CHECK (origin_lng BETWEEN -180 AND 180),
    dest_place_id INT NOT NULL REFERENCES places(place_id),
    travel_mode VARCHAR(30) NOT NULL
        CHECK (travel_mode IN ('DRIVE', 'TRANSIT', 'TWO_WHEELER', 'WALK')),
    started_at TIMESTAMPTZ NOT NULL,
    distance_km NUMERIC(6,2) NOT NULL CHECK (distance_km > 0),
    eta_minutes INT NOT NULL CHECK (eta_minutes > 0),
    actual_minutes INT CHECK (actual_minutes > 0),
    rerouted_count INT NOT NULL CHECK (rerouted_count >= 0),
    status VARCHAR(30) NOT NULL
        CHECK (status IN ('CANCELLED', 'COMPLETED', 'IN_PROGRESS'))
);

CREATE TABLE incident_reports (
    report_id INT PRIMARY KEY,
    segment_id INT NOT NULL REFERENCES road_segments(segment_id),
    user_id INT NOT NULL REFERENCES users(user_id),
    incident_type VARCHAR(30) NOT NULL
        CHECK (incident_type IN (
            'ACCIDENT', 'BREAKDOWN', 'CLOSURE',
            'POLICE', 'ROADWORK', 'WATERLOGGING'
        )),
    reported_at TIMESTAMPTZ NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    upvotes INT NOT NULL CHECK (upvotes >= 0)
);
