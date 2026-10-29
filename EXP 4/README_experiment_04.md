# Experiment 04: Joins, Subqueries, Set Operations & EXPLAIN

**File:** `experiment_04.sql` | **Database:** `CompanyDB_Exp04` | **Engine:** MySQL

## Aim
Using the Employee schema, write queries with `INNER JOIN`, `LEFT JOIN`, self-join, a 3-way join, correlated subqueries, `EXISTS`, and simulated `INTERSECT` and `EXCEPT`. Compare execution plans using `EXPLAIN`.

## Schema and data
The schema and data are the same as Experiment 03, in a separate database (`CompanyDB_Exp04`) with its own constraint names:
- `Department` (5 rows), `Project` (8 rows), `Employee` (30 rows)
- Foreign keys use `ON UPDATE CASCADE ON DELETE RESTRICT`

## Part A: Joins

| # | Query | What it shows |
|---|---|---|
| 1 | `INNER JOIN` Employee and Department | Employees matched to their department name |
| 2 | `LEFT JOIN` Department to Employee | Every department, with its employees if any |
| 3 | Self-join on `dept_id` with `E1.emp_id < E2.emp_id` | Unique pairs of colleagues in the same department. The `<` removes duplicate and self pairs. |
| 4 | 3-way join of Employee, Project, Department | Employee, project and department in one result |

## Part B: Subqueries and set operations

| # | Query | What it shows |
|---|---|---|
| 5 | Correlated subquery | Employees earning above their own department's average |
| 6 | `EXISTS` | Employees whose department has at least one project |
| 7 | Simulated `INTERSECT` using two `IN` subqueries | Employees in Delhi **and** earning above 60,000 |
| 8 | Simulated `EXCEPT` using `NOT IN` | Employees **not** in Delhi |

The native `INTERSECT` and `EXCEPT` syntax (MySQL 8.0.31 and later) is included as a commented reference under queries 7 and 8.

## Part C: EXPLAIN
`EXPLAIN` is run on four queries so their execution plans can be compared:
1. `INNER JOIN`
2. `LEFT JOIN`
3. Correlated subquery
4. `EXISTS`

Things to look at in the output: the `type` column (`ALL`, `ref`, `eq_ref`), the `key` used, estimated `rows`, and whether the subquery appears as `DEPENDENT SUBQUERY`.

## How to run
```bash
mysql -u <user> -p < experiment_04.sql
```
Each output is labelled by a `SELECT '--- ... ---' AS Query_Section;` line. The script drops and recreates its tables, so it is safe to re-run.

## Concepts demonstrated
Inner and outer joins, self-joins, multi-table joins, correlated subqueries, `EXISTS`, emulating `INTERSECT` and `EXCEPT`, reading query plans with `EXPLAIN`.
