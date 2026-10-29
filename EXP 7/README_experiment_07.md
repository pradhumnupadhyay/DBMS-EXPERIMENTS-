# Experiment 07: Normalization - UNF to 1NF, 2NF, 3NF & BCNF

**File:** `experiment_07.sql` | **Database:** `NormalizationDB_Exp07` | **Engine:** MySQL

## Aim
Identify the functional dependencies in a denormalized Sales table and normalize it step by step from UNF to 1NF, 2NF, 3NF and BCNF. Verify the lossless join and dependency preservation of the decomposition using SQL queries.

## Functional dependencies

| ID | Dependency | Meaning |
|---|---|---|
| F1 | `Order_ID -> Order_Date, Customer_ID` | An order has one date and one customer |
| F2 | `Customer_ID -> Customer_Name, Customer_City` | Customer details depend only on the customer |
| F3 | `Product_ID -> Product_Name, Category, Unit_Price` | Product details depend only on the product |
| F4 | `(Order_ID, Product_ID) -> Quantity` | Quantity depends on the whole key |
| F5 | `Salesperson_ID -> Salesperson_Name, Category` | A salesperson sells one category |
| F6 | `(Customer_ID, Category) -> Salesperson_ID` | A customer has one salesperson per category |

Each dependency is checked with a `GROUP BY ... HAVING COUNT(DISTINCT ...) > 1` query. An **empty result** means the dependency holds.

## Normalization steps

| Stage | Tables | What was fixed |
|---|---|---|
| UNF | `Sales_UNF` | Several products packed into one `Items` column |
| 1NF | `Sales_Denorm` | Atomic values, one row per `(Order_ID, Product_ID)` |
| 2NF | `Orders_2NF`, `Products`, `Order_Items_2NF` | Partial dependencies (F1, F2, F3) removed |
| 3NF | `Customers`, `Orders`, `Order_Items`, `Products`, `Salesperson`, `Customer_Rep` | Transitive dependencies removed |
| BCNF | `Salesperson_BCNF`, `Customer_Salesperson` | `Customer_Rep` split, because `Salesperson_ID -> Category` and `Salesperson_ID` is not a superkey |

## Verification

### Lossless join
The view `Sales_Rebuilt` joins the BCNF tables back together.
- The row counts of `Sales_Denorm` and `Sales_Rebuilt` are compared (7 and 7).
- A symmetric-difference query (`UNION ALL ... GROUP BY ... HAVING COUNT(*) = 1`) returns an **empty set**, so there are no missing or spurious rows.

### Dependency preservation
- F1 to F5 are enforced by the primary keys of the BCNF/3NF tables, so they are preserved.
- F6 is **not preserved** by the BCNF design. Inserting a second Electronics salesperson for customer `C1` is accepted and the check query returns `Reps = 2`.
- The 3NF table `Customer_Rep` still enforces F6 with its primary key (see the commented error test).

## Edge-case test (commented out)
Uncomment to run.

| Test | Statement | Expected message |
|---|---|---|
| 1 | `INSERT INTO Customer_Rep VALUES ('C1', 'Electronics', 'S3');` (after inserting `S3` into `Salesperson`) | `ERROR 1062 (23000): Duplicate entry 'C1-Electronics'` |

## How to run
```bash
mysql -u <user> -p < experiment_07.sql
```
The script drops its view and tables first, so it is safe to re-run.

## Concepts demonstrated
Functional dependencies, UNF/1NF/2NF/3NF/BCNF, partial and transitive dependencies, lossless-join decomposition, dependency preservation, views, `UNION ALL` set comparison.
