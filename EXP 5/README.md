# Experiment 05: Views, Updatability, and Recursive CTEs

A MySQL script that builds a small company database and demonstrates SQL views, view updatability, and a recursive Common Table Expression (CTE) for traversing an employee reporting hierarchy.

## Aim

To create SQL views for a department salary summary and an employee hierarchy, test the updatability of views, and implement a recursive CTE to display reporting chains.

## Files

| File | Description |
|------|-------------|
| `experiment_05.sql` | Complete script: schema, sample data, views, updatability tests, recursive CTE |

## Requirements

- MySQL 8.0 or later (recursive CTEs require 8.0+)
- A MySQL client such as MySQL Workbench, the `mysql` CLI, or DBeaver

## How to Run

Using the MySQL CLI:

```bash
mysql -u <username> -p < experiment_05.sql
```

Or open the file in MySQL Workbench and execute the whole script. It is safe to re-run: views and tables are dropped before being recreated.

## Database Schema

Database name: `CompanyDB_Exp05`

### `Department`

| Column | Type | Notes |
|--------|------|-------|
| `Dept_ID` | INT | Primary key |
| `Dept_Name` | VARCHAR(100) | Not null |

### `Employee`

| Column | Type | Notes |
|--------|------|-------|
| `Emp_ID` | INT | Primary key |
| `Emp_Name` | VARCHAR(100) | Not null |
| `Job_Title` | VARCHAR(100) | |
| `Salary` | DECIMAL(10,2) | |
| `Dept_ID` | INT | FK to `Department` (`ON UPDATE CASCADE`, `ON DELETE RESTRICT`) |
| `Manager_ID` | INT | Self-referencing FK to `Employee` (`ON UPDATE CASCADE`, `ON DELETE SET NULL`); `NULL` for root managers |

## Sample Data

- 5 departments: Engineering, Sales, Human Resources, Finance, Operations
- 30 employees: one root manager per department (`Manager_ID IS NULL`) plus five team members reporting to each

## Script Walkthrough

1. **Initialization and safe reset**: creates the database and drops existing views and tables in dependency order.
2. **Schema creation**: creates `Department` and `Employee` with the manager self-reference.
3. **Sample data**: inserts departments and employees.
4. **View 1, `Department_Salary_Summary`**: an aggregate view (LEFT JOIN + GROUP BY) showing per-department employee count, average, maximum, and minimum salary.
5. **View 2, `Employee_Hierarchy`**: a self-join view pairing each employee with their manager's name.
6. **View updatability tests**: updates a salary in the base table and shows the change reflected in both views.
7. **Recursive CTE, `Employee_Chain`**: starts at root managers (Level 1) and recursively walks down the reporting chain, assigning a level to each employee.

## Key Concepts

### Views

A view is a stored query that behaves like a virtual table. It holds no data itself and always reflects the current state of its base tables.

### View Updatability (MySQL)

- Views that use aggregate functions (`COUNT`, `AVG`, `MIN`, `MAX`) or `GROUP BY` are **not updatable**. For example, the following fails with Error 1288 (the target table of the UPDATE is not updatable):

  ```sql
  UPDATE Department_Salary_Summary
  SET Average_Salary = 70000
  WHERE Dept_ID = 1;
  ```

- Changes made to the underlying table are immediately visible through the views. The script demonstrates this by changing the salary of employee `1` to `63500.00`.

### Recursive CTE

- **Anchor member**: selects root managers (`Manager_ID IS NULL`) with `Level = 1`.
- **Recursive member**: joins `Employee` to the CTE on `Manager_ID = Emp_ID`, incrementing `Level` each iteration.
- Results are ordered by `Level, Emp_ID`.

## Expected Output

- Department salary summary with one row per department (5 rows)
- Employee hierarchy with each employee's manager name (30 rows; root managers show `NULL`)
- Updated salary visible in the base table and both views after the `UPDATE`
- Reporting chain: 5 employees at Level 1 (department managers) and 25 at Level 2

## Concepts Covered

`CREATE VIEW` · aggregate views · self-joins · `LEFT JOIN` · foreign keys with referential actions · view updatability · `WITH RECURSIVE` · hierarchical queries

## License

Provided for educational purposes.
