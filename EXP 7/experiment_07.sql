CREATE DATABASE IF NOT EXISTS NormalizationDB_Exp07;
USE NormalizationDB_Exp07;
DROP VIEW IF EXISTS Sales_Rebuilt;
DROP TABLE IF EXISTS Customer_Salesperson;
DROP TABLE IF EXISTS Salesperson_BCNF;
DROP TABLE IF EXISTS Customer_Rep;
DROP TABLE IF EXISTS Salesperson;
DROP TABLE IF EXISTS Order_Items;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Order_Items_2NF;
DROP TABLE IF EXISTS Orders_2NF;
DROP TABLE IF EXISTS Sales_Denorm;
DROP TABLE IF EXISTS Sales_UNF;
CREATE TABLE Sales_UNF (
    Order_ID INT PRIMARY KEY,
    Order_Date DATE,
    Customer_ID VARCHAR(5),
    Customer_Name VARCHAR(50),
    Customer_City VARCHAR(50),
    Items VARCHAR(400)
);
INSERT INTO Sales_UNF VALUES
(101, '2026-10-01', 'C1', 'Amit Sharma', 'Delhi',
 'P1:Laptop:Electronics:55000:1:S1:Karan Singh; P3:Notebook:Stationery:60:10:S2:Meera Iyer'),
(102, '2026-10-02', 'C2', 'Neha Verma', 'Mumbai',
 'P2:Mouse:Electronics:800:2:S1:Karan Singh; P4:Pen:Stationery:10:20:S2:Meera Iyer');
SELECT '--- 1. UNF: several products packed into one column ---' AS Demo_Step;
SELECT * FROM Sales_UNF;
CREATE TABLE Sales_Denorm (
    Order_ID INT,
    Order_Date DATE,
    Customer_ID VARCHAR(5),
    Customer_Name VARCHAR(50),
    Customer_City VARCHAR(50),
    Product_ID VARCHAR(5),
    Product_Name VARCHAR(50),
    Category VARCHAR(30),
    Unit_Price DECIMAL(10,2),
    Quantity INT,
    Salesperson_ID VARCHAR(5),
    Salesperson_Name VARCHAR(50),
    PRIMARY KEY (Order_ID, Product_ID)
);
INSERT INTO Sales_Denorm VALUES
(101, '2026-10-01', 'C1', 'Amit Sharma', 'Delhi',  'P1', 'Laptop',   'Electronics', 55000.00, 1,  'S1', 'Karan Singh'),
(101, '2026-10-01', 'C1', 'Amit Sharma', 'Delhi',  'P3', 'Notebook', 'Stationery',    60.00, 10, 'S2', 'Meera Iyer'),
(102, '2026-10-02', 'C2', 'Neha Verma',  'Mumbai', 'P2', 'Mouse',    'Electronics',   800.00, 2,  'S1', 'Karan Singh'),
(102, '2026-10-02', 'C2', 'Neha Verma',  'Mumbai', 'P4', 'Pen',      'Stationery',     10.00, 20, 'S2', 'Meera Iyer'),
(103, '2026-10-03', 'C1', 'Amit Sharma', 'Delhi',  'P2', 'Mouse',    'Electronics',   800.00, 1,  'S1', 'Karan Singh'),
(104, '2026-10-04', 'C3', 'Ravi Gupta',  'Kanpur', 'P3', 'Notebook', 'Stationery',     60.00, 5,  'S2', 'Meera Iyer'),
(104, '2026-10-04', 'C3', 'Ravi Gupta',  'Kanpur', 'P1', 'Laptop',   'Electronics', 55000.00, 1,  'S1', 'Karan Singh');
SELECT '--- 2. 1NF / denormalized Sales table ---' AS Demo_Step;
SELECT * FROM Sales_Denorm;
SELECT '--- 3. FD checks F1 to F6 (each must return an empty set) ---' AS Demo_Step;
SELECT Order_ID
FROM Sales_Denorm
GROUP BY Order_ID
HAVING COUNT(DISTINCT Order_Date) > 1
    OR COUNT(DISTINCT Customer_ID) > 1;
SELECT Customer_ID
FROM Sales_Denorm
GROUP BY Customer_ID
HAVING COUNT(DISTINCT Customer_Name) > 1
    OR COUNT(DISTINCT Customer_City) > 1;
SELECT Product_ID
FROM Sales_Denorm
GROUP BY Product_ID
HAVING COUNT(DISTINCT Product_Name) > 1
    OR COUNT(DISTINCT Category) > 1
    OR COUNT(DISTINCT Unit_Price) > 1;
SELECT Salesperson_ID
FROM Sales_Denorm
GROUP BY Salesperson_ID
HAVING COUNT(DISTINCT Salesperson_Name) > 1
    OR COUNT(DISTINCT Category) > 1;
SELECT Customer_ID, Category
FROM Sales_Denorm
GROUP BY Customer_ID, Category
HAVING COUNT(DISTINCT Salesperson_ID) > 1;
CREATE TABLE Orders_2NF (
    Order_ID INT PRIMARY KEY,
    Order_Date DATE,
    Customer_ID VARCHAR(5),
    Customer_Name VARCHAR(50),
    Customer_City VARCHAR(50)
);
CREATE TABLE Products (
    Product_ID VARCHAR(5) PRIMARY KEY,
    Product_Name VARCHAR(50),
    Category VARCHAR(30),
    Unit_Price DECIMAL(10,2)
);
CREATE TABLE Order_Items_2NF (
    Order_ID INT,
    Product_ID VARCHAR(5),
    Quantity INT,
    Salesperson_ID VARCHAR(5),
    Salesperson_Name VARCHAR(50),
    PRIMARY KEY (Order_ID, Product_ID)
);
INSERT INTO Orders_2NF
SELECT DISTINCT Order_ID, Order_Date, Customer_ID, Customer_Name, Customer_City
FROM Sales_Denorm;
INSERT INTO Products
SELECT DISTINCT Product_ID, Product_Name, Category, Unit_Price
FROM Sales_Denorm;
INSERT INTO Order_Items_2NF
SELECT Order_ID, Product_ID, Quantity, Salesperson_ID, Salesperson_Name
FROM Sales_Denorm;
SELECT '--- 4. 2NF tables ---' AS Demo_Step;
SELECT * FROM Orders_2NF;
SELECT * FROM Products;
SELECT * FROM Order_Items_2NF;
CREATE TABLE Customers (
    Customer_ID VARCHAR(5) PRIMARY KEY,
    Customer_Name VARCHAR(50),
    Customer_City VARCHAR(50)
);
CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY,
    Order_Date DATE,
    Customer_ID VARCHAR(5),
    CONSTRAINT fk_exp7_orders_customer
        FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID)
);
CREATE TABLE Order_Items (
    Order_ID INT,
    Product_ID VARCHAR(5),
    Quantity INT,
    PRIMARY KEY (Order_ID, Product_ID),
    CONSTRAINT fk_exp7_items_order
        FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID),
    CONSTRAINT fk_exp7_items_product
        FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID)
);
CREATE TABLE Salesperson (
    Salesperson_ID VARCHAR(5) PRIMARY KEY,
    Salesperson_Name VARCHAR(50)
);
CREATE TABLE Customer_Rep (
    Customer_ID VARCHAR(5),
    Category VARCHAR(30),
    Salesperson_ID VARCHAR(5),
    PRIMARY KEY (Customer_ID, Category),
    CONSTRAINT fk_exp7_rep_customer
        FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID),
    CONSTRAINT fk_exp7_rep_salesperson
        FOREIGN KEY (Salesperson_ID) REFERENCES Salesperson(Salesperson_ID)
);
INSERT INTO Customers
SELECT DISTINCT Customer_ID, Customer_Name, Customer_City
FROM Orders_2NF;
INSERT INTO Orders
SELECT Order_ID, Order_Date, Customer_ID
FROM Orders_2NF;
INSERT INTO Order_Items
SELECT Order_ID, Product_ID, Quantity
FROM Order_Items_2NF;
INSERT INTO Salesperson
SELECT DISTINCT Salesperson_ID, Salesperson_Name
FROM Order_Items_2NF;
INSERT INTO Customer_Rep
SELECT DISTINCT o.Customer_ID, p.Category, oi.Salesperson_ID
FROM Order_Items_2NF oi
JOIN Orders_2NF o ON o.Order_ID = oi.Order_ID
JOIN Products p ON p.Product_ID = oi.Product_ID;
SELECT '--- 5. 3NF tables ---' AS Demo_Step;
SELECT * FROM Customers;
SELECT * FROM Orders;
SELECT * FROM Order_Items;
SELECT * FROM Salesperson;
SELECT * FROM Customer_Rep;
CREATE TABLE Salesperson_BCNF (
    Salesperson_ID VARCHAR(5) PRIMARY KEY,
    Salesperson_Name VARCHAR(50),
    Category VARCHAR(30)
);
CREATE TABLE Customer_Salesperson (
    Customer_ID VARCHAR(5),
    Salesperson_ID VARCHAR(5),
    PRIMARY KEY (Customer_ID, Salesperson_ID),
    CONSTRAINT fk_exp7_cs_customer
        FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID),
    CONSTRAINT fk_exp7_cs_salesperson
        FOREIGN KEY (Salesperson_ID) REFERENCES Salesperson_BCNF(Salesperson_ID)
);
INSERT INTO Salesperson_BCNF
SELECT DISTINCT s.Salesperson_ID, s.Salesperson_Name, cr.Category
FROM Salesperson s
JOIN Customer_Rep cr ON cr.Salesperson_ID = s.Salesperson_ID;
INSERT INTO Customer_Salesperson
SELECT DISTINCT Customer_ID, Salesperson_ID
FROM Customer_Rep;
SELECT '--- 6. BCNF tables ---' AS Demo_Step;
SELECT * FROM Salesperson_BCNF;
SELECT * FROM Customer_Salesperson;
CREATE VIEW Sales_Rebuilt AS
SELECT o.Order_ID, o.Order_Date,
       c.Customer_ID, c.Customer_Name, c.Customer_City,
       p.Product_ID, p.Product_Name, p.Category, p.Unit_Price,
       oi.Quantity, sb.Salesperson_ID, sb.Salesperson_Name
FROM Orders o
JOIN Customers c ON c.Customer_ID = o.Customer_ID
JOIN Order_Items oi ON oi.Order_ID = o.Order_ID
JOIN Products p ON p.Product_ID = oi.Product_ID
JOIN Customer_Salesperson cs ON cs.Customer_ID = o.Customer_ID
JOIN Salesperson_BCNF sb ON sb.Salesperson_ID = cs.Salesperson_ID
                        AND sb.Category = p.Category;
SELECT '--- 7. Row counts (original vs rebuilt) ---' AS Demo_Step;
SELECT (SELECT COUNT(*) FROM Sales_Denorm) AS Original_Rows,
       (SELECT COUNT(*) FROM Sales_Rebuilt) AS Rebuilt_Rows;
SELECT '--- 8. Symmetric difference (must be an empty set) ---' AS Demo_Step;
SELECT Order_ID, Order_Date, Customer_ID, Customer_Name, Customer_City,
       Product_ID, Product_Name, Category, Unit_Price, Quantity,
       Salesperson_ID, Salesperson_Name
FROM (
    SELECT * FROM Sales_Denorm
    UNION ALL
    SELECT * FROM Sales_Rebuilt
) AS t
GROUP BY Order_ID, Order_Date, Customer_ID, Customer_Name, Customer_City,
         Product_ID, Product_Name, Category, Unit_Price, Quantity,
         Salesperson_ID, Salesperson_Name
HAVING COUNT(*) = 1;
INSERT INTO Salesperson_BCNF VALUES ('S3', 'Rohan Das', 'Electronics');
INSERT INTO Customer_Salesperson VALUES ('C1', 'S3');
SELECT '--- 9. F6 violated in the BCNF design (customer C1 has 2 Electronics reps) ---' AS Demo_Step;
SELECT cs.Customer_ID, sb.Category, COUNT(*) AS Reps
FROM Customer_Salesperson cs
JOIN Salesperson_BCNF sb ON sb.Salesperson_ID = cs.Salesperson_ID
GROUP BY cs.Customer_ID, sb.Category
HAVING COUNT(*) > 1;
DELETE FROM Customer_Salesperson WHERE Customer_ID = 'C1' AND Salesperson_ID = 'S3';
DELETE FROM Salesperson_BCNF WHERE Salesperson_ID = 'S3';
