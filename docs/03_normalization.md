# Database Normalization

## 1. Introduction

Normalization is the process of organizing database tables to reduce
duplicate data and avoid insertion, update and deletion problems.

This project uses three normal forms: 1NF, 2NF and 3NF.

## 2. First Normal Form (1NF)

A table is in 1NF when:
- Each column stores a single value.
- There are no repeating groups of columns.
- Each row can be uniquely identified.

In this project:
- Each place has its own row in the places table.
- Opening hours are stored as separate rows for each weekday.
- Reviews and traffic readings are stored as separate records.

This keeps the data organized into individual records.

## 3. Second Normal Form (2NF)

A table is in 2NF when:
- It is already in 1NF.
- Every non-key column depends on the complete candidate key.

Most tables use a single-column primary key, so partial dependency
does not arise in those tables.

Two examples use composite primary keys:

- opening_hours: (place_id, weekday) determines opens and closes.
- saved_places: (user_id, place_id, list_name) determines saved_at.

Their non-key attributes depend on the complete composite key.

## 4. Third Normal Form (3NF)

A table is in 3NF when:
- It is already in 2NF.
- Non-key attributes do not depend on other non-key attributes.

The schema separates related information into different tables.
For example:
- City details are stored in cities.
- Category details are stored in place_categories.
- Place details refer to cities and categories using foreign keys.
- Review details are stored separately in place_reviews.

This reduces repeated storage of city, category and review information.

## 5. Primary and Composite Keys

| Table | Primary Key |
|---|---|
| cities | city_id |
| place_categories | category_id |
| users | user_id |
| places | place_id |
| opening_hours | (place_id, weekday) |
| place_reviews | review_id |
| saved_places | (user_id, place_id, list_name) |
| road_segments | segment_id |
| traffic_readings | reading_id |
| navigation_sessions | session_id |
| incident_reports | report_id |

The users table also has a unique email constraint, and the places
table has a unique plus_code constraint.

## 6. Design Note

The places table stores avg_rating and review_count along with place
details. These values summarize information available from reviews.

They are kept in the table as summary fields for place-related queries.
If review data changes, these summary values must also be updated
correctly to avoid inconsistent information.

## 7. Conclusion

The database uses separate tables for different entities and uses
primary keys, foreign keys and composite keys to maintain relationships.

The design follows the principles of 1NF, 2NF and 3NF based on the
functional dependencies considered during schema design.
