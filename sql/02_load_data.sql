\set ON_ERROR_STOP on

SET search_path TO gmaps;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM cities LIMIT 1)
       OR EXISTS (SELECT 1 FROM place_categories LIMIT 1)
       OR EXISTS (SELECT 1 FROM users LIMIT 1)
       OR EXISTS (SELECT 1 FROM places LIMIT 1)
       OR EXISTS (SELECT 1 FROM opening_hours LIMIT 1)
       OR EXISTS (SELECT 1 FROM road_segments LIMIT 1)
       OR EXISTS (SELECT 1 FROM place_reviews LIMIT 1)
       OR EXISTS (SELECT 1 FROM saved_places LIMIT 1)
       OR EXISTS (SELECT 1 FROM traffic_readings LIMIT 1)
       OR EXISTS (SELECT 1 FROM navigation_sessions LIMIT 1)
       OR EXISTS (SELECT 1 FROM incident_reports LIMIT 1)
    THEN
        RAISE EXCEPTION 'Data already exists. Do not run this loading script again without clearing the tables first.';
    END IF;
END $$;

\copy cities FROM 'seed_data/cities.csv' WITH (FORMAT csv, HEADER true);
\copy place_categories FROM 'seed_data/place_categories.csv' WITH (FORMAT csv, HEADER true);
\copy users FROM 'seed_data/users.csv' WITH (FORMAT csv, HEADER true);
\copy places FROM 'seed_data/places.csv' WITH (FORMAT csv, HEADER true);
\copy opening_hours FROM 'seed_data/opening_hours.csv' WITH (FORMAT csv, HEADER true);
\copy road_segments FROM 'seed_data/road_segments.csv' WITH (FORMAT csv, HEADER true);
\copy place_reviews FROM 'seed_data/place_reviews.csv' WITH (FORMAT csv, HEADER true);
\copy saved_places FROM 'seed_data/saved_places.csv' WITH (FORMAT csv, HEADER true);
\copy traffic_readings FROM 'seed_data/traffic_readings.csv' WITH (FORMAT csv, HEADER true);
\copy navigation_sessions FROM 'seed_data/navigation_sessions.csv' WITH (FORMAT csv, HEADER true);
\copy incident_reports FROM 'seed_data/incident_reports.csv' WITH (FORMAT csv, HEADER true);

ANALYZE;
