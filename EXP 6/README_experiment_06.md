# Experiment 06: Stored Procedures, Validation Triggers & Audit Logging

**File:** `experiment_06.sql` | **Database:** `CompanyDB_Exp06` | **Engine:** MySQL

## Aim
Create a stored procedure `transfer_employee(emp_id, new_dept_id)` with validation and error handling. Implement triggers for salary validation and audit logging, and test edge cases.

## Schema

| Table | Columns | Purpose |
|---|---|---|
| `Department` | `Dept_ID`, `Dept_Name` | Departments (Sales, Engineering) |
| `Employee` | `Emp_ID`, `Emp_Name`, `Salary`, `Dept_ID` | Employees (Alex, salary 60,000, in Sales) |
| `Salary_Audit` | `Audit_ID` (auto-increment), `Emp_ID`, `Old_Salary`, `New_Salary`, `Changed_At` | Log of every salary change |

## Objects created

### Procedure `transfer_employee(p_emp_id, p_new_dept_id)`
Checks that the employee and the target department exist, then updates `Employee.Dept_ID`. Failures raise a custom error with `SIGNAL SQLSTATE '45000'`:
- `Employee does not exist`
- `Department does not exist`

### Trigger `before_employee_salary_update` (BEFORE UPDATE)
Blocks any update that would set a negative salary, with the message `Salary cannot be negative`.

### Trigger `after_employee_salary_update` (AFTER UPDATE)
Inserts a row into `Salary_Audit` with the old and new salary, but only when the salary actually changed (`OLD.Salary <> NEW.Salary`).

## Demonstration flow
1. Show Alex's initial record (Dept 1, Sales).
2. `CALL transfer_employee(1, 2)` moves Alex to Engineering, and the record is shown again.
3. Show `Salary_Audit`. It is empty at this point, because a department transfer does not change the salary.
4. `UPDATE Employee SET Salary = 65000 WHERE Emp_ID = 1`.
5. Show `Salary_Audit` again. It now has one row: 60,000 to 65,000.
6. Show Alex's final record (salary 65,000, Dept 2).

## Edge-case tests (commented out)
Uncomment one at a time. Each raises `ERROR 1644 (45000)`:

| Test | Statement | Expected message |
|---|---|---|
| 1 | `CALL transfer_employee(999, 2);` | Employee does not exist |
| 2 | `CALL transfer_employee(1, 999);` | Department does not exist |
| 3 | `UPDATE Employee SET Salary = -5000 WHERE Emp_ID = 1;` | Salary cannot be negative |

## How to run
```bash
mysql -u <user> -p < experiment_06.sql
```
The script uses `DELIMITER $$` to define the procedure and triggers. `DELIMITER` is a client-side command, so it works in the `mysql` command-line client and MySQL Workbench but not through every driver or API. The script drops its procedure, triggers and tables first, so it is safe to re-run.

## Concepts demonstrated
Stored procedures, `IN` parameters, input validation, `SIGNAL` error handling, `BEFORE` and `AFTER` triggers, `OLD` and `NEW` row references, audit tables.
