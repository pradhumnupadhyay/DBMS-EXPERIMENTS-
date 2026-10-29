# Experiment 03: Employee-Department-Project Queries & Aggregations

**File:** `experiment_03.sql` | **Database:** `CompanyDB_Exp03` | **Engine:** MySQL

## Aim
Create an Employee-Department-Project schema with at least 30 employees across 5 departments and 8 projects. Write SQL queries showing selection, projection, aggregates, `GROUP BY`, `HAVING`, `CASE` expressions and `ORDER BY`.

## Schema

| Table | Columns | Keys |
|---|---|---|
| `Department` | `dept_id`, `dept_name` | PK `dept_id` |
| `Project` | `project_id`, `project_name`, `dept_id` | PK `project_id`; FK `dept_id` to `Department` |
| `Employee` | `emp_id`, `emp_name`, `dept_id`, `project_id`, `salary`, `city` | PK `emp_id`; FKs to `Department` and `Project` |

All foreign keys use `ON UPDATE CASCADE ON DELETE RESTRICT`.

## Sample data
- **5 departments:** HR, Finance, IT, Marketing, Operations
- **8 projects:** Recruitment System, Payroll Automation, Cybersecurity Upgrade, Website Revamp, Ad Campaign, Market Research, Logistics Optimization, Inventory System
- **30 employees:** spread over the 5 departments and 8 projects, in cities including Delhi, Mumbai, Pune, Lucknow, Chennai, Bangalore and Hyderabad. Salaries run from 42,000 to 72,000.

Employees per department: HR 5, Finance 5, IT 7, Marketing 6, Operations 7.

## Queries

| # | Concept | Query |
|---|---|---|
| 1 | Selection (`WHERE`) | Employees located in Delhi (9 rows) |
| 2 | Projection | Only `emp_name` and `salary` |
| 3 | Aggregate + `GROUP BY` | Average salary per department |
| 4 | `HAVING` | Departments with more than 5 employees (IT, Marketing, Operations) |
| 5 | `CASE` | Salary category: **Low** (< 50,000), **Medium** (50,000 to 60,000), **High** (above 60,000) |
| 6 | `ORDER BY` | All employees sorted by salary, highest first |

## How to run
```bash
mysql -u <user> -p < experiment_03.sql
```
Each query is preceded by a `SELECT '--- ... ---' AS Query_Demo;` line that labels its output. The script drops and recreates its tables, so it is safe to re-run.

## Concepts demonstrated
Filtering, projection, `AVG` / `COUNT`, `GROUP BY`, `HAVING` vs `WHERE`, searched `CASE`, `ORDER BY ... DESC`.
