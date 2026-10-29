# Experiment 10: Query Analysis & Optimization using EXPLAIN

**File:** `experiment_10.sql` | **Database:** `OptimizationDB_Exp10` | **Engine:** MySQL 8.0+ (InnoDB)

## Aim
Generate a dataset of at least 10,000 rows and write five slow queries. Analyze them using `EXPLAIN`, optimize them using indexing and query rewriting, and compare the execution time before and after optimization.

## Schema

| Table | Columns | Purpose |
|---|---|---|
| `Customers` | `Cust_ID`, `Cust_Name`, `Email`, `City`, `Signup_Date`, `Status` | 10,000 generated customers |
| `Orders` | `Order_ID`, `Cust_ID`, `Order_Date`, `Amount`, `Product_Category`, `Order_Status` | 20,000 generated orders |
| `Query_Benchmark` | `Run_ID`, `Query_No`, `Version`, `Loops`, `Total_ms`, `Avg_ms` | Timing results for each run |

No secondary indexes and no foreign key are created at first, so that the queries start out slow.

## The five slow queries and their fixes

| Query | Problem | Fix |
|---|---|---|
| Q1 | `YEAR()` / `MONTH()` on `Order_Date` (non-sargable) | Date range filter, covering index `idx_orders_date_cover` |
| Q2 | `LIKE '%1234@example.com'` (leading wildcard) | Equality lookup, index `idx_cust_email` |
| Q3 | Correlated subquery run once per customer | Join with a pre-aggregated table, indexes `idx_cust_city`, `idx_orders_cust_amt` |
| Q4 | `SELECT *` with `ORDER BY ... LIMIT` (filesort) | Select only the needed columns, composite index `idx_orders_status_date` |
| Q5 | `NOT IN` subquery | `NOT EXISTS`, index `idx_orders_cust_status` |

### Procedure `run_query(p_no, p_ver, p_loops)`
Runs query `p_no` (1 to 5) in its `BEFORE` (slow) or `AFTER` (optimized) form `p_loops` times. It stores the total and average time in `Query_Benchmark`.

## Demonstration flow
1. Create the tables and generate the data, then show the row counts.
2. Run `EXPLAIN` on the five slow queries (plus `EXPLAIN ANALYZE` on Q3).
3. Record baseline timings with `run_query(..., 'BEFORE', ...)`. Q3 uses only 2 loops because it is the slowest.
4. Create the indexes.
5. Run `EXPLAIN` on the rewritten queries.
6. Record timings with `run_query(..., 'AFTER', ...)`.
7. The final `SELECT` shows `Before_ms`, `After_ms` and `Speedup_x` for each query.

Timings depend on your machine, so run the script and record your own numbers.

## How to run
```bash
mysql -u <user> -p < experiment_10.sql
```
The script uses `DELIMITER $$`, a client-side command, so it works in the `mysql` command-line client and MySQL Workbench. It drops its procedure and tables first, so it is safe to re-run.

## Concepts demonstrated
`EXPLAIN` / `EXPLAIN ANALYZE`, full table scans, sargable predicates, covering and composite indexes, filesort, correlated subqueries vs joins, `NOT IN` vs `NOT EXISTS`, benchmarking with stored procedures.
