# CP3 — Database Optimization Report

## 1. Objective

Optimize the Google Maps database workload using indexes and query-level improvements while preserving the original workload and query semantics.

## 2. Methodology

- Database: `de_gmaps`
- Workload: 25 read queries (R01–R25) and 5 write queries (W01–W05)
- Benchmark runs: 3 per query per phase
- Measurement: `EXPLAIN (ANALYZE, BUFFERS)`
- Baseline: `benchmarks/results/baseline/summary.csv`
- Optimized: `benchmarks/results/optimized/summary.csv`
- Original workload `queries/workload_30.sql` was not modified.

## 3. Indexes Added

| Index | Purpose |
|---|---|
| idx_places_active_category_location | R01: nearby active restaurants |
| idx_places_active_city_category | R04: active restaurants by city/category |
| idx_opening_hours_weekday_place | R02, R04: weekday opening hours |
| idx_traffic_segment_recorded | R07, R09: traffic history by segment/time |
| idx_navigation_started_dest | R12, R16, R20: navigation time filtering |
| idx_navigation_origin_place | R13: navigation origin lookup |
| idx_navigation_dest_started | R19: destination navigation lookup |
| idx_reviews_place_created | R05: newest reviews for a place |
| idx_reviews_created | R14, R22: date filtering and newest-first review listing |

## 4. Query Optimization

### R19 — Hospital navigation report

The original query used two correlated subqueries against `navigation_sessions` for every hospital. The optimized query aggregates navigation sessions once by destination and LEFT JOINs the result with hospitals.

This preserves hospitals with zero navigations using `COALESCE`.

## 5. Benchmark Results

All values are average execution time in milliseconds. Positive change means faster; negative change means slower.

| Query | Baseline | Optimized | Change |
|---|---:|---:|---:|
| R01 | 5.964 | 0.366 | +93.9% |
| R02 | 0.045 | 0.218 | -384.4% |
| R03 | 15.699 | 16.173 | -3.0% |
| R04 | 8.120 | 4.011 | +50.6% |
| R05 | 0.170 | 0.232 | -36.5% |
| R06 | 0.086 | 0.393 | -357.0% |
| R07 | 9.505 | 2.051 | +78.4% |
| R08 | 7.199 | 0.537 | +92.5% |
| R09 | 4.593 | 0.257 | +94.4% |
| R10 | 0.742 | 0.964 | -29.9% |
| R11 | 24.329 | 22.649 | +6.9% |
| R12 | 9.660 | 2.670 | +72.4% |
| R13 | 19.715 | 15.954 | +19.1% |
| R14 | 8.296 | 6.094 | +26.5% |
| R15 | 34.065 | 34.241 | -0.5% |
| R16 | 12.735 | 7.442 | +41.6% |
| R17 | 35.259 | 30.627 | +13.1% |
| R18 | 13.998 | 16.354 | -16.8% |
| R19 | 12076.201 | 28.952 | +99.8% |
| R20 | 9.314 | 10.160 | -9.1% |
| R21 | 19.726 | 20.662 | -4.7% |
| R22 | 17.523 | 3.838 | +78.1% |
| R23 | 0.024 | 0.023 | +4.2% |
| R24 | 4.376 | 4.473 | -2.2% |
| R25 | 26.333 | 27.169 | -3.2% |
| W01 | 0.617 | 0.764 | -23.8% |
| W02 | 0.544 | 0.535 | +1.7% |
| W03 | 0.480 | 1.001 | -108.5% |
| W04 | 42.085 | 43.738 | -3.9% |
| W05 | 2.118 | 1.947 | +8.1% |

## 6. Key Findings

- R19 improved from 12,076.201 ms to 28.952 ms, approximately 99.8% faster.
- R01, R07, R08, R09, R12 and R22 showed substantial improvements.
- R04, R13, R14, R16 and R17 also improved.
- Some queries regressed, particularly R02, R05, R06, R10, R18, R20, R21, R24 and R25.
- Write-query overhead increased for W01, W03 and W04. W03 increased from 0.480 ms to 1.001 ms, although the absolute difference is small.
- R03 remains a sequential scan because its leading-wildcard `ILIKE '%biryani%'` predicate is not supported by an ordinary B-tree index.
- R19 now performs one grouped aggregation instead of repeatedly scanning the navigation table for each hospital.

## 7. Limitations

- Results depend on database cache state, hardware, PostgreSQL configuration and data distribution.
- Three benchmark runs provide a useful comparison but are not a complete production workload evaluation.
- Indexes consume storage and add write-maintenance overhead.
- Further tuning should prioritize queries with meaningful absolute execution time, not percentage changes alone.

## 8. Conclusion

CP3 introduced nine indexes and an aggregation-based rewrite of R19. The most significant improvement was R19, which reduced execution time from approximately 12.08 seconds to 28.95 milliseconds.

The optimized workload completed all 30 queries. Performance regressions are documented rather than hidden. Further tuning should be guided by execution plans and repeatable measurements.
