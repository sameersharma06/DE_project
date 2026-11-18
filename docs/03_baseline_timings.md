# CP2 – Baseline Performance Timings

## 1. Benchmark Overview

- Total queries: 30
- Read queries: 25
- Write queries: 5
- Runs per query: 3
- Measurement: EXPLAIN (ANALYZE, BUFFERS)
- Database: de_gmaps
- Phase: baseline

## 2. Query-wise Results

| Query | Type | Run 1 (ms) | Run 2 (ms) | Run 3 (ms) | Average (ms) |
|---|---|---:|---:|---:|---:|
| R01 | READ | 7.685 | 5.499 | 4.707 | 5.964 |
| R02 | READ | 0.052 | 0.040 | 0.042 | 0.045 |
| R03 | READ | 18.329 | 15.834 | 12.934 | 15.699 |
| R04 | READ | 9.118 | 7.707 | 7.536 | 8.120 |
| R05 | READ | 0.227 | 0.144 | 0.139 | 0.170 |
| R06 | READ | 0.088 | 0.061 | 0.109 | 0.086 |
| R07 | READ | 10.808 | 8.806 | 8.901 | 9.505 |
| R08 | READ | 7.066 | 7.221 | 7.311 | 7.199 |
| R09 | READ | 4.630 | 4.454 | 4.694 | 4.593 |
| R10 | READ | 0.838 | 0.698 | 0.691 | 0.742 |
| R11 | READ | 23.321 | 25.246 | 24.421 | 24.329 |
| R12 | READ | 9.756 | 9.794 | 9.429 | 9.660 |
| R13 | READ | 19.286 | 21.225 | 18.633 | 19.715 |
| R14 | READ | 8.520 | 8.336 | 8.032 | 8.296 |
| R15 | READ | 34.007 | 34.266 | 33.923 | 34.065 |
| R16 | READ | 12.710 | 13.076 | 12.418 | 12.735 |
| R17 | READ | 32.339 | 31.525 | 41.912 | 35.259 |
| R18 | READ | 14.127 | 14.433 | 13.435 | 13.998 |
| R19 | READ | 12008.856 | 12082.373 | 12137.374 | 12076.201 |
| R20 | READ | 10.196 | 8.814 | 8.931 | 9.314 |
| R21 | READ | 19.993 | 19.387 | 19.799 | 19.726 |
| R22 | READ | 17.699 | 17.699 | 17.171 | 17.523 |
| R23 | READ | 0.026 | 0.025 | 0.022 | 0.024 |
| R24 | READ | 4.374 | 4.301 | 4.453 | 4.376 |
| R25 | READ | 25.681 | 27.109 | 26.209 | 26.333 |
| W01 | WRITE | 0.889 | 0.474 | 0.487 | 0.617 |
| W02 | WRITE | 0.693 | 0.472 | 0.466 | 0.544 |
| W03 | WRITE | 0.526 | 0.460 | 0.455 | 0.480 |
| W04 | WRITE | 56.559 | 35.084 | 34.612 | 42.085 |
| W05 | WRITE | 2.402 | 2.019 | 1.934 | 2.118 |

## 3. Slowest Queries

| Query | Type | Average (ms) | Execution plan scan nodes |
|---|---|---:|---|
| R19 | READ | 12076.201 | Seq Scan on place_categories ; Seq Scan on places ; Seq Scan on navigation_sessions |
| W04 | WRITE | 42.085 | Seq Scan on places ; Seq Scan on place_reviews |
| R17 | READ | 35.259 | Seq Scan on navigation_sessions |
| R15 | READ | 34.065 | Index Scan using places_pkey on places ; Index Scan using unique_place_user_review on place_reviews |
| R25 | READ | 26.333 | Seq Scan on traffic_readings ; Seq Scan on road_segments |

## 4. Baseline Observations

- R19 is the slowest query at 12076.201 ms.
- R19 performs sequential scans on place_categories, places and navigation_sessions.
- Several read queries use sequential scans on large tables such as navigation_sessions and traffic_readings.
- Primary-key and unique-key index scans are visible in queries such as R02, R05, R06 and R23.
- W04 takes longer than the other write queries because it scans places and place_reviews.
- These observations identify possible optimization targets; no optimization is applied in this baseline report.

## 5. Baseline Artifacts

- Raw execution plans: `benchmarks/results/baseline/`
- Summary CSV: `benchmarks/results/baseline/summary.csv`

## 6. Schema Compatibility Notes

- `navigation_sessions.rerouted_count` was given DEFAULT 0 so W01 can insert a new session.
- `place_reviews` was given UNIQUE (place_id, user_id) so W02 ON CONFLICT can execute.
- These changes were made to align the schema with the write workload. Confirm these constraints with the project mentor before final submission.
