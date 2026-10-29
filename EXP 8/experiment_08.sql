CREATE DATABASE IF NOT EXISTS BankDB_Exp08;
USE BankDB_Exp08;

DROP PROCEDURE IF EXISTS safe_transfer;
DROP TABLE IF EXISTS Txn_Log;
DROP TABLE IF EXISTS Account;

CREATE TABLE Account (
    Acc_No INT PRIMARY KEY,
    Holder_Name VARCHAR(50) NOT NULL,
    Balance DECIMAL(12,2) NOT NULL,
    CONSTRAINT chk_balance CHECK (Balance >= 0)
) ENGINE = InnoDB;

CREATE TABLE Txn_Log (
    Txn_ID INT AUTO_INCREMENT PRIMARY KEY,
    From_Acc INT,
    To_Acc INT,
    Amount DECIMAL(12,2),
    Txn_Time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

INSERT INTO Account VALUES
(101, 'Amit', 10000.00),
(102, 'Neha',  5000.00),
(103, 'Ravi',  2000.00);

SELECT '--- 1. Initial State ---' AS Demo_Step;
SELECT * FROM Account;

BEGIN;
UPDATE Account SET Balance = Balance - 2000 WHERE Acc_No = 101;
UPDATE Account SET Balance = Balance + 2000 WHERE Acc_No = 102;
INSERT INTO Txn_Log (From_Acc, To_Acc, Amount) VALUES (101, 102, 2000.00);
COMMIT;

SELECT '--- 2. After COMMIT (101 = 8000, 102 = 7000) ---' AS Demo_Step;
SELECT * FROM Account;
SELECT * FROM Txn_Log;

START TRANSACTION;
UPDATE Account SET Balance = Balance - 1000 WHERE Acc_No = 101;
UPDATE Account SET Balance = Balance + 1000 WHERE Acc_No = 102;

SELECT '--- 3. Inside the transaction (101 = 7000, 102 = 8000) ---' AS Demo_Step;
SELECT * FROM Account;

ROLLBACK;

SELECT '--- 4. After ROLLBACK (balances restored) ---' AS Demo_Step;
SELECT * FROM Account;

START TRANSACTION;
UPDATE Account SET Balance = Balance - 500 WHERE Acc_No = 101;
SAVEPOINT after_debit;

UPDATE Account SET Balance = Balance + 500 WHERE Acc_No = 102;

ROLLBACK TO SAVEPOINT after_debit;

UPDATE Account SET Balance = Balance + 500 WHERE Acc_No = 103;
COMMIT;

SELECT '--- 5. After SAVEPOINT demo (101 = 7500, 102 = 7000, 103 = 2500) ---' AS Demo_Step;
SELECT * FROM Account;

DELIMITER $$

CREATE PROCEDURE safe_transfer(
    IN p_from INT,
    IN p_to INT,
    IN p_amt DECIMAL(12,2)
)
BEGIN
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Transaction failed - rolled back' AS Status;
    END;

    START TRANSACTION;
    UPDATE Account SET Balance = Balance - p_amt WHERE Acc_No = p_from;
    UPDATE Account SET Balance = Balance + p_amt WHERE Acc_No = p_to;
    INSERT INTO Txn_Log (From_Acc, To_Acc, Amount) VALUES (p_from, p_to, p_amt);
    COMMIT;
    SELECT 'Transaction committed' AS Status;
END $$

DELIMITER ;

CALL safe_transfer(102, 103, 1000.00);

CALL safe_transfer(103, 101, 99999.00);

SELECT '--- 6. After safe_transfer calls (101 = 7500, 102 = 6000, 103 = 3500) ---' AS Demo_Step;
SELECT * FROM Account;
SELECT * FROM Txn_Log;

SELECT @@transaction_isolation;

UPDATE Account SET Balance = 9500.00 WHERE Acc_No = 101;

UPDATE Account SET Balance = 9500.00 WHERE Acc_No = 101;
