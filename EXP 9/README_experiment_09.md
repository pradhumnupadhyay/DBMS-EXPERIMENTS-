# Experiment 09: Indexing & Query Performance Benchmarking (Railway Booking)

**File:** `experiment_09.sql` | **Database:** `RailwayDB_Exp09` | **Engine:** MySQL 8.0+ (InnoDB)

## Aim
Create a Railway Booking table with at least 5,000 records. Benchmark query performance before and after creating single and composite indexes, and compare the execution plans using `EXPLAIN`.

## Schema

| Table | Columns | Purpose |
|---|---|---|
| `Railway_Booking` | `Booking_ID`, `PNR_No`, `Passenger_Name`, `Age`, `Train_No`, `From_Station`, `To_Station`, `Journey_Date`, `Class_Type`, `Seat_No`, `Fare`, `Booking_Status` | 10,000 generated bookings |

The data is generated with a recursive CTE (`cte_max_recursion_depth` is raised for the session). There are 50 trains, 90 journey dates and 4 classes.

## Queries benchmarked

| Query | Filter |
|---|---|
| Q1 | `Train_No = 12010` |
| Q2 | `Train_No = 12010 AND Journey_Date = '2026-11-11' AND Class_Type = '3A'` |

### Procedure `run_benchmark(p_query_id, p_loops)`
Runs query 1 or 2 in a loop (500 loops in the script) and prints `Total_ms`, the elapsed time in milliseconds.

## Stages

| Stage | Index | Expected plan |
|---|---|---|
| 1 | Primary key only | `type = ALL` (full table scan, about 10,000 rows) |
| 2 | `idx_train (Train_No)` | `type = ref`, `key = idx_train`, about 200 rows |
| 3 | `idx_train_date_class (Train_No, Journey_Date, Class_Type)` | `type = ref`, `key = idx_train_date_class`, about 12 rows for Q2 |
| 4 | Left-most prefix test (`Journey_Date` only) | `type = ALL`, the composite index is not used |

At each stage the script runs `EXPLAIN` (and `EXPLAIN ANALYZE` for key steps) and then the benchmark. Compare the `Total_ms` values across stages.

Row estimates are approximate. Timings depend on your machine, so run the script and record your own numbers.

## How to run
```bash
mysql -u <user> -p < experiment_09.sql
```
The script uses `DELIMITER $$`, a client-side command, so it works in the `mysql` command-line client and MySQL Workbench. It drops its procedure and table first, so it is safe to re-run.

## Concepts demonstrated
B-tree indexes, single-column vs composite indexes, the left-most prefix rule, `EXPLAIN` / `EXPLAIN ANALYZE`, full table scan vs index lookup, benchmarking with stored procedures, index storage cost.
