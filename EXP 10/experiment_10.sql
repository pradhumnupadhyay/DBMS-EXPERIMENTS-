CREATE DATABASE IF NOT EXISTS OptimizationDB_Exp10;
USE OptimizationDB_Exp10;
DROP PROCEDURE IF EXISTS run_query;
DROP TABLE IF EXISTS Query_Benchmark;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;
CREATE TABLE Customers (
    Cust_ID INT PRIMARY KEY,
    Cust_Name VARCHAR(50),
    Email VARCHAR(80),
    City VARCHAR(30),
    Signup_Date DATE,
    Status VARCHAR(10)
) ENGINE = InnoDB;
CREATE TABLE Orders (
    Order_ID INT AUTO_INCREMENT PRIMARY KEY,
    Cust_ID INT NOT NULL,
    Order_Date DATE,
    Amount DECIMAL(10,2),
    Product_Category VARCHAR(30),
    Order_Status VARCHAR(12)
) ENGINE = InnoDB;
CREATE TABLE Query_Benchmark (
    Run_ID INT AUTO_INCREMENT PRIMARY KEY,
    Query_No INT,
    Version VARCHAR(10),
    Loops INT,
    Total_ms DECIMAL(12,3),
    Avg_ms DECIMAL(12,3)
);
SET SESSION cte_max_recursion_depth = 30000;
INSERT INTO Customers
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 10000
)
SELECT n,
       CONCAT('Customer_', n),
       CONCAT('user', n, '@example.com'),
       ELT(1 + (n % 6), 'Delhi', 'Kanpur', 'Mumbai', 'Chennai', 'Kolkata', 'Pune'),
       DATE_ADD('2022-01-01', INTERVAL (n % 1000) DAY),
       ELT(1 + (n % 3), 'ACTIVE', 'INACTIVE', 'PENDING')
FROM seq;
INSERT INTO Orders (Cust_ID, Order_Date, Amount, Product_Category, Order_Status)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 20000
)
SELECT 1 + ((n * 7) % 10000),
       DATE_ADD('2024-01-01', INTERVAL (n % 730) DAY),
       ROUND(100 + (n % 500) * 9.75, 2),
       ELT(1 + (n % 5), 'Electronics', 'Grocery', 'Clothing', 'Books', 'Toys'),
       ELT(1 + (n % 4), 'DELIVERED', 'SHIPPED', 'PENDING', 'CANCELLED')
FROM seq;
ANALYZE TABLE Customers, Orders;
SELECT '--- 1. Dataset size ---' AS Demo_Step;
SELECT (SELECT COUNT(*) FROM Customers) AS Customer_Rows,
       (SELECT COUNT(*) FROM Orders) AS Order_Rows;
DELIMITER $$
CREATE PROCEDURE run_query(IN p_no INT, IN p_ver VARCHAR(10), IN p_loops INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE v_cnt INT;
    DECLARE v_start DATETIME(6);
    DECLARE v_ms DECIMAL(12,3);
    SET v_start = NOW(6);
    WHILE i < p_loops DO
        IF p_ver = 'BEFORE' THEN
            CASE p_no
                WHEN 1 THEN
                    SELECT COUNT(*) INTO v_cnt FROM (
                        SELECT Order_ID, Cust_ID, Amount FROM Orders
                        WHERE YEAR(Order_Date) = 2025 AND MONTH(Order_Date) = 3) AS q;
                WHEN 2 THEN
                    SELECT COUNT(*) INTO v_cnt FROM (
                        SELECT Cust_ID, Cust_Name, Email FROM Customers
                        WHERE Email LIKE '%1234@example.com') AS q;
                WHEN 3 THEN
                    SELECT COUNT(*) INTO v_cnt FROM (
                        SELECT c.Cust_ID, c.Cust_Name,
                               (SELECT SUM(o.Amount) FROM Orders o
                                WHERE o.Cust_ID = c.Cust_ID) AS Total_Spent
                        FROM Customers c
                        WHERE c.City = 'Kanpur') AS q;
                WHEN 4 THEN
                    SELECT COUNT(*) INTO v_cnt FROM (
                        SELECT * FROM Orders
                        WHERE Order_Status = 'PENDING'
                        ORDER BY Order_Date DESC
                        LIMIT 10) AS q;
                WHEN 5 THEN
                    SELECT COUNT(*) INTO v_cnt FROM (
                        SELECT Cust_ID, Cust_Name FROM Customers
                        WHERE Cust_ID NOT IN (SELECT Cust_ID FROM Orders
                                              WHERE Order_Status = 'CANCELLED')) AS q;
            END CASE;
        ELSE
            CASE p_no
                WHEN 1 THEN
                    SELECT COUNT(*) INTO v_cnt FROM (
                        SELECT Order_ID, Cust_ID, Amount FROM Orders
                        WHERE Order_Date >= '2025-03-01'
                          AND Order_Date < '2025-04-01') AS q;
                WHEN 2 THEN
                    SELECT COUNT(*) INTO v_cnt FROM (
                        SELECT Cust_ID, Cust_Name, Email FROM Customers
                        WHERE Email = 'user1234@example.com') AS q;
                WHEN 3 THEN
                    SELECT COUNT(*) INTO v_cnt FROM (
                        SELECT c.Cust_ID, c.Cust_Name, t.Total_Spent
                        FROM Customers c
                        LEFT JOIN (SELECT Cust_ID, SUM(Amount) AS Total_Spent
                                   FROM Orders
                                   GROUP BY Cust_ID) t
                               ON t.Cust_ID = c.Cust_ID
                        WHERE c.City = 'Kanpur') AS q;
                WHEN 4 THEN
                    SELECT COUNT(*) INTO v_cnt FROM (
                        SELECT Order_ID, Cust_ID, Order_Date, Amount FROM Orders
                        WHERE Order_Status = 'PENDING'
                        ORDER BY Order_Date DESC
                        LIMIT 10) AS q;
                WHEN 5 THEN
                    SELECT COUNT(*) INTO v_cnt FROM (
                        SELECT c.Cust_ID, c.Cust_Name FROM Customers c
                        WHERE NOT EXISTS (SELECT 1 FROM Orders o
                                          WHERE o.Cust_ID = c.Cust_ID
                                            AND o.Order_Status = 'CANCELLED')) AS q;
            END CASE;
        END IF;
        SET i = i + 1;
    END WHILE;
    SET v_ms = TIMESTAMPDIFF(MICROSECOND, v_start, NOW(6)) / 1000;
    INSERT INTO Query_Benchmark (Query_No, Version, Loops, Total_ms, Avg_ms)
    VALUES (p_no, p_ver, p_loops, v_ms, v_ms / p_loops);
END $$
DELIMITER ;
SELECT '--- 2. Q1: function applied to the column (non-sargable) ---' AS Demo_Step;
EXPLAIN SELECT Order_ID, Cust_ID, Amount FROM Orders
WHERE YEAR(Order_Date) = 2025 AND MONTH(Order_Date) = 3;
SELECT '--- 3. Q2: leading wildcard in LIKE ---' AS Demo_Step;
EXPLAIN SELECT Cust_ID, Cust_Name, Email FROM Customers
WHERE Email LIKE '%1234@example.com';
SELECT '--- 4. Q3: correlated subquery executed once per customer ---' AS Demo_Step;
EXPLAIN SELECT c.Cust_ID, c.Cust_Name,
       (SELECT SUM(o.Amount) FROM Orders o WHERE o.Cust_ID = c.Cust_ID) AS Total_Spent
FROM Customers c
WHERE c.City = 'Kanpur';
SELECT '--- 5. Q4: SELECT * with filter and ORDER BY ... LIMIT (filesort) ---' AS Demo_Step;
EXPLAIN SELECT * FROM Orders
WHERE Order_Status = 'PENDING'
ORDER BY Order_Date DESC
LIMIT 10;
SELECT '--- 6. Q5: NOT IN subquery ---' AS Demo_Step;
EXPLAIN SELECT Cust_ID, Cust_Name FROM Customers
WHERE Cust_ID NOT IN (SELECT Cust_ID FROM Orders WHERE Order_Status = 'CANCELLED');
SELECT '--- 7. EXPLAIN ANALYZE of Q3 (actual execution detail) ---' AS Demo_Step;
EXPLAIN ANALYZE SELECT c.Cust_ID, c.Cust_Name,
       (SELECT SUM(o.Amount) FROM Orders o WHERE o.Cust_ID = c.Cust_ID) AS Total_Spent
FROM Customers c
WHERE c.City = 'Kanpur';
CALL run_query(1, 'BEFORE', 50);
CALL run_query(2, 'BEFORE', 50);
CALL run_query(3, 'BEFORE', 2);
CALL run_query(4, 'BEFORE', 50);
CALL run_query(5, 'BEFORE', 50);
CREATE INDEX idx_orders_date_cover ON Orders (Order_Date, Cust_ID, Amount);
CREATE INDEX idx_cust_email ON Customers (Email);
CREATE INDEX idx_cust_city ON Customers (City);
CREATE INDEX idx_orders_cust_amt ON Orders (Cust_ID, Amount);
CREATE INDEX idx_orders_status_date ON Orders (Order_Status, Order_Date);
CREATE INDEX idx_orders_cust_status ON Orders (Cust_ID, Order_Status);
ANALYZE TABLE Customers, Orders;
SELECT '--- 8. Q1 optimized: date range instead of YEAR()/MONTH() ---' AS Demo_Step;
EXPLAIN SELECT Order_ID, Cust_ID, Amount FROM Orders
WHERE Order_Date >= '2025-03-01' AND Order_Date < '2025-04-01';
SELECT '--- 9. Q2 optimized: equality lookup instead of leading-wildcard LIKE ---' AS Demo_Step;
EXPLAIN SELECT Cust_ID, Cust_Name, Email FROM Customers
WHERE Email = 'user1234@example.com';
SELECT '--- 10. Q3 optimized: join with a pre-aggregated table ---' AS Demo_Step;
EXPLAIN SELECT c.Cust_ID, c.Cust_Name, t.Total_Spent
FROM Customers c
LEFT JOIN (SELECT Cust_ID, SUM(Amount) AS Total_Spent
           FROM Orders
           GROUP BY Cust_ID) t
       ON t.Cust_ID = c.Cust_ID
WHERE c.City = 'Kanpur';
SELECT '--- 11. Q4 optimized: only the needed columns, composite index serves filter and sort ---' AS Demo_Step;
EXPLAIN SELECT Order_ID, Cust_ID, Order_Date, Amount FROM Orders
WHERE Order_Status = 'PENDING'
ORDER BY Order_Date DESC
LIMIT 10;
SELECT '--- 12. Q5 optimized: NOT EXISTS (anti-join using idx_orders_cust_status) ---' AS Demo_Step;
EXPLAIN SELECT c.Cust_ID, c.Cust_Name
FROM Customers c
WHERE NOT EXISTS (SELECT 1 FROM Orders o
                  WHERE o.Cust_ID = c.Cust_ID
                    AND o.Order_Status = 'CANCELLED');
CALL run_query(1, 'AFTER', 50);
CALL run_query(2, 'AFTER', 50);
CALL run_query(3, 'AFTER', 50);
CALL run_query(4, 'AFTER', 50);
CALL run_query(5, 'AFTER', 50);
SELECT '--- 13. Before / After comparison ---' AS Demo_Step;
SELECT Query_No,
       ROUND(MAX(CASE WHEN Version = 'BEFORE' THEN Avg_ms END), 3) AS Before_ms,
       ROUND(MAX(CASE WHEN Version = 'AFTER'  THEN Avg_ms END), 3) AS After_ms,
       ROUND(MAX(CASE WHEN Version = 'BEFORE' THEN Avg_ms END) /
             MAX(CASE WHEN Version = 'AFTER'  THEN Avg_ms END), 1) AS Speedup_x
FROM Query_Benchmark
GROUP BY Query_No
ORDER BY Query_No;
