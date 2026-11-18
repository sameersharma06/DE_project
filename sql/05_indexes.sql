SET search_path TO gmaps;

-- R01: Nearby active restaurants
CREATE INDEX IF NOT EXISTS idx_places_active_category_location
ON places (category_id, latitude, longitude)
WHERE is_permanently_closed = false;

-- R04: Active restaurants by city and category
CREATE INDEX IF NOT EXISTS idx_places_active_city_category
ON places (city_id, category_id, place_id)
WHERE is_permanently_closed = false;

-- R04: Opening hours by weekday and place
CREATE INDEX IF NOT EXISTS idx_opening_hours_weekday_place
ON opening_hours (weekday, place_id)
INCLUDE (opens, closes);

-- R07, R09: Traffic history by segment and latest timestamp
CREATE INDEX IF NOT EXISTS idx_traffic_segment_recorded
ON traffic_readings (segment_id, recorded_at DESC)
INCLUDE (avg_speed_kmph, congestion_level);

-- R12, R16, R20: Navigation sessions by time
CREATE INDEX IF NOT EXISTS idx_navigation_started_dest
ON navigation_sessions (started_at, dest_place_id);

-- R13: Find places that were never navigation origins
CREATE INDEX IF NOT EXISTS idx_navigation_origin_place
ON navigation_sessions (origin_place_id);

-- R19: Navigation count and latest navigation by destination
CREATE INDEX IF NOT EXISTS idx_navigation_dest_started
ON navigation_sessions (dest_place_id, started_at DESC);

-- R05: Latest reviews for a specific place
CREATE INDEX IF NOT EXISTS idx_reviews_place_created
ON place_reviews (place_id, created_at DESC);

-- R14, R22: Recent reviews and date-based review analysis
CREATE INDEX IF NOT EXISTS idx_reviews_created
ON place_reviews (created_at DESC)
INCLUDE (review_id, place_id, user_id, rating, photo_count);
