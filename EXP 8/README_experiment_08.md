# Experiment 08: Transactions, Savepoints & Concurrency Control

**File:** `experiment_08.sql` | **Database:** `BankDB_Exp08` | **Engine:** MySQL 8.0.16+ (InnoDB)

## Aim
Implement banking-style transactions using `BEGIN`, `COMMIT`, `ROLLBACK` and `SAVEPOINT`. Simulate partial failures, and demonstrate isolation levels and concurrency anomalies using two sessions.

## Schema

| Table | Columns | Purpose |
|---|---|---|
| `Account` | `Acc_No`, `Holder_Name`, `Balance` (`CHECK Balance >= 0`) | Bank accounts: Amit 10,000, Neha 5,000, Ravi 2,000 |
| `Txn_Log` | `Txn_ID` (auto-increment), `From_Acc`, `To_Acc`, `Amount`, `Txn_Time` | Record of completed transfers |

## Parts

| Part | Demonstrates | Result |
|---|---|---|
| A | `BEGIN` ... `COMMIT` | 2,000 moves from 101 to 102 and is logged (8,000 / 7,000) |
| B | `START TRANSACTION` ... `ROLLBACK` | A 1,000 transfer is cancelled and balances return to normal |
| C | `SAVEPOINT` and `ROLLBACK TO SAVEPOINT` | A credit to the wrong account is undone, the debit is kept (7,500 / 7,000 / 2,500) |
| D | Procedure `safe_transfer(from, to, amount)` with an `EXIT HANDLER` | A valid transfer is committed, and an overdraft breaks the `CHECK` and is fully rolled back |
| E | Two-session isolation tests | See the table below |

### Procedure `safe_transfer(p_from, p_to, p_amt)`
Starts a transaction, debits and credits the accounts, and writes to `Txn_Log`. Any SQL error triggers `ROLLBACK` and returns `Transaction failed - rolled back`. Otherwise it commits and returns `Transaction committed`.

## Part E: concurrency tests
Open **two connections** to `BankDB_Exp08` and run the commented `Session 1` / `Session 2` lines in the order given in the script.

| Test | Isolation level | Observation | Anomaly |
|---|---|---|---|
| E1 | `READ UNCOMMITTED` | Session 2 reads 1.00 before Session 1 rolls back | Dirty read |
| E2 | `READ COMMITTED` | The same row reads 7,500 and then 8,500 in one transaction | Non-repeatable read |
| E3 | `REPEATABLE READ` | Both reads return the same value | Prevented |
| E4 | `READ COMMITTED` | `COUNT(*)` changes from 2 to 3 after another session inserts a row | Phantom read |
| E5(a) | `REPEATABLE READ` | Final balance 9,700 (the +100 is overwritten) | Lost update |
| E5(b) | `SELECT ... FOR UPDATE` | Session 2 waits, final balance 9,800 | Prevented |

## Edge-case test (commented out)
Uncomment to run.

| Test | Statement | Expected message |
|---|---|---|
| 1 | `UPDATE Account SET Balance = Balance - 5000 WHERE Acc_No = 103;` | `ERROR 3819 (HY000): Check constraint 'chk_balance' is violated.` |

## How to run
Parts A to D run top to bottom:
```bash
mysql -u <user> -p < experiment_08.sql
```
Part E is a manual two-terminal exercise. Its lines are commented out in the script. The script uses `DELIMITER $$`, a client-side command, so it works in the `mysql` command-line client and MySQL Workbench. It drops its procedure and tables first, so it is safe to re-run.

## Concepts demonstrated
ACID transactions, `COMMIT`, `ROLLBACK`, `SAVEPOINT`, `CHECK` constraints, exit handlers, isolation levels, dirty/non-repeatable/phantom reads, lost updates, row locking with `FOR UPDATE`.
