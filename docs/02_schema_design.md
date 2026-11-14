# Schema Design

## 1. Database Overview

- Database: PostgreSQL 16
- Schema: gmaps
- Tables: 11
- Total loaded records: 936,328

## 2. Table Relationships

| Parent Table | Child Table | Relationship |
|---|---|---|
| cities | places | One-to-Many |
| place_categories | places | One-to-Many |
| cities | users | One-to-Many |
| places | opening_hours | One-to-Many |
| places | place_reviews | One-to-Many |
| users | place_reviews | One-to-Many |
| users | saved_places | One-to-Many |
| places | saved_places | One-to-Many |
| cities | road_segments | One-to-Many |
| road_segments | traffic_readings | One-to-Many |
| users | navigation_sessions | One-to-Many |
| places | navigation_sessions | Origin / Destination |
| road_segments | incident_reports | One-to-Many |
| users | incident_reports | One-to-Many |

## 3. Data Dictionary

### cities
| Column | Type | Constraint |
|---|---|---|
| city_id | INT | PK |
| city_name | VARCHAR(100) | NOT NULL |
| center_lat | NUMERIC(9,6) | NOT NULL, CHECK |
| center_lng | NUMERIC(9,6) | NOT NULL, CHECK |

### place_categories
| Column | Type | Constraint |
|---|---|---|
| category_id | INT | PK |
| category_name | VARCHAR(100) | NOT NULL |

### users
| Column | Type | Constraint |
|---|---|---|
| user_id | INT | PK |
| display_name | VARCHAR(150) | NOT NULL |
| email | VARCHAR(255) | UNIQUE, NOT NULL |
| home_city_id | INT | FK, NULL allowed |
| is_local_guide | BOOLEAN | NOT NULL |
| guide_level | SMALLINT | CHECK 1–10, NULL allowed |
| created_at | TIMESTAMPTZ | NOT NULL |

### places
| Column | Type | Constraint |
|---|---|---|
| place_id | INT | PK |
| plus_code | VARCHAR(30) | UNIQUE, NOT NULL |
| name | VARCHAR(255) | NOT NULL |
| category_id | INT | FK, NOT NULL |
| city_id | INT | FK, NOT NULL |
| latitude | NUMERIC(9,6) | NOT NULL, CHECK |
| longitude | NUMERIC(9,6) | NOT NULL, CHECK |
| address | TEXT | NOT NULL |
| phone | VARCHAR(30) | NULL allowed |
| website | TEXT | NULL allowed |
| price_level | SMALLINT | CHECK 1–4, NULL allowed |
| avg_rating | NUMERIC(2,1) | CHECK 1–5, NULL allowed |
| review_count | INT | NOT NULL, CHECK >= 0 |
| is_permanently_closed | BOOLEAN | NOT NULL |
| created_at | TIMESTAMPTZ | NOT NULL |

### opening_hours
| Column | Type | Constraint |
|---|---|---|
| place_id | INT | PK, FK |
| weekday | SMALLINT | PK, CHECK 1–7 |
| opens | TIME | NOT NULL |
| closes | TIME | NOT NULL |

### place_reviews
| Column | Type | Constraint |
|---|---|---|
| review_id | INT | PK |
| place_id | INT | FK, NOT NULL |
| user_id | INT | FK, NOT NULL |
| rating | NUMERIC(2,1) | NOT NULL, CHECK 1–5 |
| review_text | TEXT | NULL allowed |
| photo_count | SMALLINT | NOT NULL, CHECK >= 0 |
| created_at | TIMESTAMPTZ | NOT NULL |

### saved_places
| Column | Type | Constraint |
|---|---|---|
| user_id | INT | PK, FK |
| place_id | INT | PK, FK |
| list_name | VARCHAR(100) | PK, NOT NULL |
| saved_at | TIMESTAMPTZ | NOT NULL |

### road_segments
| Column | Type | Constraint |
|---|---|---|
| segment_id | INT | PK |
| road_name | VARCHAR(255) | NOT NULL |
| city_id | INT | FK, NOT NULL |
| road_type | VARCHAR(100) | NOT NULL |
| start_lat | NUMERIC(9,6) | NOT NULL, CHECK |
| start_lng | NUMERIC(9,6) | NOT NULL, CHECK |
| end_lat | NUMERIC(9,6) | NOT NULL, CHECK |
| end_lng | NUMERIC(9,6) | NOT NULL, CHECK |
| length_m | INT | NOT NULL, CHECK > 0 |
| speed_limit_kmph | SMALLINT | NOT NULL, CHECK > 0 |

### traffic_readings
| Column | Type | Constraint |
|---|---|---|
| reading_id | BIGINT | PK |
| segment_id | INT | FK, NOT NULL |
| recorded_at | TIMESTAMPTZ | NOT NULL |
| avg_speed_kmph | NUMERIC(5,2) | NOT NULL, CHECK >= 0 |
| congestion_level | VARCHAR(20) | NOT NULL, CHECK allowed values |

### navigation_sessions
| Column | Type | Constraint |
|---|---|---|
| session_id | BIGINT | PK |
| user_id | INT | FK, NULL allowed |
| origin_place_id | INT | FK, NULL allowed |
| origin_lat | NUMERIC(9,6) | NOT NULL, CHECK |
| origin_lng | NUMERIC(9,6) | NOT NULL, CHECK |
| dest_place_id | INT | FK, NOT NULL |
| travel_mode | VARCHAR(30) | NOT NULL, CHECK allowed values |
| started_at | TIMESTAMPTZ | NOT NULL |
| distance_km | NUMERIC(6,2) | NOT NULL, CHECK > 0 |
| eta_minutes | INT | NOT NULL, CHECK > 0 |
| actual_minutes | INT | NULL allowed, CHECK > 0 |
| rerouted_count | INT | NOT NULL, CHECK >= 0 |
| status | VARCHAR(30) | NOT NULL, CHECK allowed values |

### incident_reports
| Column | Type | Constraint |
|---|---|---|
| report_id | INT | PK |
| segment_id | INT | FK, NOT NULL |
| user_id | INT | FK, NOT NULL |
| incident_type | VARCHAR(30) | NOT NULL, CHECK allowed values |
| reported_at | TIMESTAMPTZ | NOT NULL |
| expires_at | TIMESTAMPTZ | NOT NULL |
| upvotes | INT | NOT NULL, CHECK >= 0 |

## 4. Functional Dependencies and Normalization

The following dependencies are based on the selected primary and unique keys.

| Table | Functional Dependency | Normal Form |
|---|---|---|
| cities | city_id -> city_name, center_lat, center_lng | 3NF |
| place_categories | category_id -> category_name | 3NF |
| users | user_id -> other attributes; email -> user_id | 3NF |
| places | place_id -> other attributes; plus_code -> place_id | 3NF |
| opening_hours | (place_id, weekday) -> opens, closes | 3NF |
| place_reviews | review_id -> other attributes | 3NF |
| saved_places | (user_id, place_id, list_name) -> saved_at | 3NF |
| road_segments | segment_id -> other attributes | 3NF |
| traffic_readings | reading_id -> other attributes | 3NF |
| navigation_sessions | session_id -> other attributes | 3NF |
| incident_reports | report_id -> other attributes | 3NF |

Each table has atomic attributes and non-key attributes depend on the complete candidate key. Separate tables are used for independently repeating entities such as reviews, opening hours and traffic readings.

## 5. Data Quality Observations

- `places.phone` has 12,008 missing values.
- `places.website` has 28,007 missing values.
- `places.price_level` has 26,667 missing values.
- `places.avg_rating` has 5,611 missing values.
- `users.home_city_id` has 4,032 missing values.
- `users.guide_level` has 36,088 missing values.
- `navigation_sessions.user_id` has 40,275 missing values.
- `navigation_sessions.origin_place_id` has 192,584 missing values.
- `navigation_sessions.actual_minutes` has 29,935 missing values.
- `place_reviews.review_text` has 36,035 missing values.

These optional values are kept nullable instead of being replaced with artificial defaults.

## 6. Verification Results

### Row Count Verification

| Table | Expected | Loaded |
|---|---:|---:|
| cities | 10 | 10 |
| place_categories | 12 | 12 |
| places | 40,042 | 40,042 |
| opening_hours | 252,266 | 252,266 |
| users | 40,000 | 40,000 |
| place_reviews | 89,998 | 89,998 |
| saved_places | 50,000 | 50,000 |
| road_segments | 2,000 | 2,000 |
| traffic_readings | 250,000 | 250,000 |
| navigation_sessions | 200,000 | 200,000 |
| incident_reports | 12,000 | 12,000 |

### Integrity Checks

| Check | Invalid Records |
|---|---:|
| Places with missing city/category | 0 |
| Reviews with missing place/user | 0 |
| Traffic readings with missing segment | 0 |
| Duplicate saved places | 0 |
| Invalid review ratings | 0 |

All five SQL integrity checks returned zero invalid records.

### Foreign Key Profiling

All 15 foreign-key reference checks performed on the CSV dataset returned zero orphan records.

### Duplicate Profiling

All 11 primary/composite key candidate checks returned zero duplicate records.

## 7. Design Rationale

The following design choices were made based on the dataset and application requirements:

| Design Choice | Reason |
|---|---|
| Primary keys | Uniquely identify each record and prevent duplicate entities. |
| Foreign keys | Maintain valid relationships between cities, places, users, roads and related records. |
| Composite key in opening_hours | A place can have one opening-hours record per weekday. |
| Composite key in saved_places | A user can save a place under a particular list without creating duplicate entries in that list. |
| UNIQUE email | Prevents multiple user accounts from using the same email address. |
| UNIQUE plus_code | Ensures each place has a unique location identifier. |
| NUMERIC for coordinates | Preserves decimal precision for geographic locations. |
| NUMERIC for ratings and speeds | Supports decimal values without unnecessary floating-point approximation. |
| TIMESTAMPTZ | Stores timestamps with timezone information for reviews, traffic and navigation events. |
| BIGINT for high-volume IDs | Provides sufficient integer range for traffic readings and navigation sessions. |
| Nullable optional fields | Preserves missing source values instead of inserting artificial defaults. |
| CHECK constraints | Restrict ratings, coordinates, counts and category values to valid ranges. |

The columns store the following business information:

- `cities`: identifies cities and their geographic centres.
- `place_categories`: stores categories used to classify places.
- `users`: stores user profiles, guide status and optional home-city information.
- `places`: stores place identity, location, contact details, ratings and closure status.
- `opening_hours`: stores opening and closing times for each place and weekday.
- `place_reviews`: stores user ratings, review text and photo counts.
- `saved_places`: connects users with places saved in their lists.
- `road_segments`: stores road identity, geographic endpoints and speed limits.
- `traffic_readings`: stores time-based traffic speed and congestion information.
- `navigation_sessions`: stores navigation origin, destination, travel mode and trip outcomes.
- `incident_reports`: stores user-reported road incidents, expiry times and upvotes.

## 8. Conclusion

The database schema was created in PostgreSQL 16 and all 11 CSV files were loaded successfully. The loaded row counts match the supplied dataset counts. The five SQL integrity checks passed with zero invalid records.
