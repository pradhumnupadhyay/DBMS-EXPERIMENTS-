CREATE DATABASE IF NOT EXISTS RailwayDB_Exp09;
USE RailwayDB_Exp09;
DROP PROCEDURE IF EXISTS run_benchmark;
DROP TABLE IF EXISTS Railway_Booking;
CREATE TABLE Railway_Booking (
    Booking_ID INT AUTO_INCREMENT PRIMARY KEY,
    PNR_No CHAR(10) NOT NULL,
    Passenger_Name VARCHAR(50),
    Age INT,
    Train_No INT NOT NULL,
    From_Station VARCHAR(30),
    To_Station VARCHAR(30),
    Journey_Date DATE NOT NULL,
    Class_Type CHAR(3) NOT NULL,
    Seat_No INT,
    Fare DECIMAL(8,2),
    Booking_Status VARCHAR(10)
) ENGINE = InnoDB;
SET SESSION cte_max_recursion_depth = 20000;
INSERT INTO Railway_Booking
    (PNR_No, Passenger_Name, Age, Train_No, From_Station, To_Station,
     Journey_Date, Class_Type, Seat_No, Fare, Booking_Status)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 10000
)
SELECT LPAD(n, 10, '0'),
       CONCAT('Passenger_', n),
       18 + (n % 60),
       12000 + (n % 50),
       ELT(1 + (n % 5), 'Delhi', 'Kanpur', 'Mumbai', 'Chennai', 'Kolkata'),
       ELT(1 + ((n + 2) % 5), 'Delhi', 'Kanpur', 'Mumbai', 'Chennai', 'Kolkata'),
       DATE_ADD('2026-11-01', INTERVAL (n % 90) DAY),
       ELT(1 + (n % 4), '1A', '2A', '3A', 'SL'),
       1 + (n % 72),
       ROUND(300 + (n % 40) * 55.5, 2),
       ELT(1 + (n % 3), 'CONFIRMED', 'WAITING', 'RAC')
FROM seq;
ANALYZE TABLE Railway_Booking;
SELECT '--- 1. Record count (must be at least 5000) ---' AS Demo_Step;
SELECT COUNT(*) AS Total_Records FROM Railway_Booking;
SELECT * FROM Railway_Booking LIMIT 5;
DELIMITER $$
CREATE PROCEDURE run_benchmark(IN p_query_id INT, IN p_loops INT)
BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE v_cnt INT;
    DECLARE v_start DATETIME(6);
    SET v_start = NOW(6);
    WHILE i < p_loops DO
        IF p_query_id = 1 THEN
            SELECT COUNT(*) INTO v_cnt
            FROM Railway_Booking
            WHERE Train_No = 12010;
        ELSEIF p_query_id = 2 THEN
            SELECT COUNT(*) INTO v_cnt
            FROM Railway_Booking
            WHERE Train_No = 12010
              AND Journey_Date = '2026-11-11'
              AND Class_Type = '3A';
        END IF;
        SET i = i + 1;
    END WHILE;
    SELECT p_query_id AS Query_ID,
           p_loops AS Loops,
           ROUND(TIMESTAMPDIFF(MICROSECOND, v_start, NOW(6)) / 1000, 2) AS Total_ms;
END $$
DELIMITER ;
SELECT '--- 2. EXPLAIN Q1 before index (expect type = ALL) ---' AS Demo_Step;
EXPLAIN SELECT * FROM Railway_Booking WHERE Train_No = 12010;
SELECT '--- 3. EXPLAIN Q2 before index (expect type = ALL) ---' AS Demo_Step;
EXPLAIN SELECT * FROM Railway_Booking
WHERE Train_No = 12010 AND Journey_Date = '2026-11-11' AND Class_Type = '3A';
SELECT '--- 4. EXPLAIN ANALYZE Q1 before index ---' AS Demo_Step;
EXPLAIN ANALYZE SELECT * FROM Railway_Booking WHERE Train_No = 12010;
SELECT '--- 5. Benchmark before index (500 loops each) ---' AS Demo_Step;
CALL run_benchmark(1, 500);
CALL run_benchmark(2, 500);
CREATE INDEX idx_train ON Railway_Booking (Train_No);
SELECT '--- 6. EXPLAIN Q1 with single index (expect type = ref, key = idx_train) ---' AS Demo_Step;
EXPLAIN SELECT * FROM Railway_Booking WHERE Train_No = 12010;
SELECT '--- 7. EXPLAIN Q2 with single index (idx_train used, rows filtered afterwards) ---' AS Demo_Step;
EXPLAIN SELECT * FROM Railway_Booking
WHERE Train_No = 12010 AND Journey_Date = '2026-11-11' AND Class_Type = '3A';
SELECT '--- 8. Benchmark with single index (500 loops each) ---' AS Demo_Step;
CALL run_benchmark(1, 500);
CALL run_benchmark(2, 500);
CREATE INDEX idx_train_date_class
ON Railway_Booking (Train_No, Journey_Date, Class_Type);
SELECT '--- 9. EXPLAIN Q2 with composite index (expect key = idx_train_date_class) ---' AS Demo_Step;
EXPLAIN SELECT * FROM Railway_Booking
WHERE Train_No = 12010 AND Journey_Date = '2026-11-11' AND Class_Type = '3A';
SELECT '--- 10. EXPLAIN ANALYZE Q2 with composite index ---' AS Demo_Step;
EXPLAIN ANALYZE SELECT * FROM Railway_Booking
WHERE Train_No = 12010 AND Journey_Date = '2026-11-11' AND Class_Type = '3A';
SELECT '--- 11. Benchmark with composite index (500 loops) ---' AS Demo_Step;
CALL run_benchmark(2, 500);
SELECT '--- 12. Left-most prefix test (expect type = ALL) ---' AS Demo_Step;
EXPLAIN SELECT * FROM Railway_Booking WHERE Journey_Date = '2026-11-11';
SELECT '--- 13. Indexes on the table ---' AS Demo_Step;
SHOW INDEX FROM Railway_Booking;
SELECT '--- 14. Storage used by data and indexes ---' AS Demo_Step;
SELECT TABLE_NAME,
       ROUND(DATA_LENGTH / 1024) AS Data_KB,
       ROUND(INDEX_LENGTH / 1024) AS Index_KB
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'Railway_Booking';
