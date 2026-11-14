# Problem Understanding

## Project Overview

This project is based on a Google Maps-like navigation system.
The database stores information about cities, places, users, reviews,
saved places, roads, traffic readings, navigation sessions and incident reports.

The main purpose is to organize this information so that it can be
stored, searched and used efficiently.

## Business Problems and Stakeholders

| ID | Business Need | Stakeholder | Classification |
|---|---|---|---|
| P1 | Improve nearby and open-now searches, including places closing after midnight | Search | Customer-facing / Real-time |
| P2 | Improve place details, opening hours, latest reviews and Saved tab performance | Places | Customer-facing |
| P3 | Refresh traffic and incident information every minute | Traffic | Real-time |
| P4 | Improve traffic charts and road-safety reports | Traffic | Reporting / Analytics |
| P5 | Improve ETA accuracy, rerouting and navigation startup | Routing / ETA | Customer-facing / Real-time |
| P6 | Identify places never used as a navigation starting point | Data Team | Reporting / Analytics |
| P7 | Detect stale ratings, closed places, missing hours and duplicate listings | Data Quality | Data Quality / Analytics |
| P8 | Improve leaderboards, moderation and health reports while supporting 20x navigation growth | Community / Analytics | Reporting / Analytics |

## Main Data Entities

- Cities store information about different cities.
- Place categories are used to classify places.
- Places store location and business information.
- Opening hours store the operating schedule of each place.
- Users can write reviews and save places.
- Road segments store information about roads.
- Traffic readings store traffic conditions for road segments.
- Navigation sessions record users' journeys.
- Incident reports store information about incidents on roads.

## Assumptions

1. Most tables use a separate ID as their primary key. The opening_hours and saved_places tables use composite primary keys.
2. Each place belongs to one city and one category.
3. A place can have multiple reviews and can be saved by multiple users.
4. A road segment can have multiple traffic readings and incident reports.
5. A navigation session may not have an associated user or origin place because these fields allow NULL values.
6. Optional information, such as a user's home city or a place's phone number, can be NULL.
7. The supplied CSV files are used as the source data for the initial database load.
