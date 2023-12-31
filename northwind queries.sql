-- SELECT all
SELECT * FROM Employees;

-- INSERT
INSERT INTO Employees (LastName, FirstName, BirthDate)
values  ("Valentine", "Nat", "1996-08-13"),
		("Test", "John", "1985-01-02");
		
-- UPDATE
UPDATE Employees SET FirstName = "Dave" WHERE FirstName = "John";

-- DELETE
DELETE FROM Employees WHERE FirstName = "Dave"; -- Don't forget to add the WHERE clause unless you want to delete all data from the table

-- Aliases
SELECT FirstName AS Nombre, LastName AS Apellido FROM Employees;

SELECT Price AS Precio, Price * 2 AS Precio_doble FROM Products;

-- ORDER BY
SELECT * FROM Products ORDER BY Price ASC NULLS LAST;

SELECT * FROM Products ORDER BY Price DESC NULLS FIRST;

SELECT * FROM Products ORDER BY RANDOM();

SELECT * FROM Products ORDER BY SupplierID, ProductName;

-- Sin repetidos
SELECT DISTINCT ProductName FROM Products;

-- Filtrar registros (WHERE)
SELECT * FROM Products WHERE ProductID = 5;

SELECT * FROM Products WHERE Price > 40;

UPDATE Products SET Price = 420.69 WHERE ProductID = 20; -- Modificar ciertos registros

-- Operadores lógicos y de comparación
SELECT * FROM Customers WHERE CustomerID >= 50 AND CustomerID < 55;

SELECT * FROM Customers WHERE CustomerID = 50 OR CustomerID = 55;

SELECT * FROM Employees WHERE FirstName = "Nancy" OR FirstName = "Anne";

SELECT * FROM Products WHERE (Price < 20 OR CategoryID = 6) AND SupplierID = 7;

SELECT * FROM Products WHERE NOT Price > 40;

SELECT * FROM Customers WHERE NOT Country = "USA";

SELECT * FROM Customers WHERE NOT Country = "USA" AND NOT Country = "France";

SELECT * FROM Customers WHERE CustomerID >= 50 AND CustomerID < 55 AND NOT Country = "Germany";

SELECT * FROM Customers WHERE CustomerID >= 50 AND NOT Country = "Germany" LIMIT 5;

SELECT * FROM Products WHERE NOT CategoryID = 6 AND NOT SupplierID = 1 AND Price <= 30 ORDER BY RANDOM() LIMIT 3;

SELECT * FROM Products WHERE Price BETWEEN 20 AND 40;

SELECT * FROM Products WHERE Price BETWEEN 20 AND 40 AND CategoryID = 6;

SELECT * FROM Products WHERE Price NOT BETWEEN 10 AND 40;

SELECT * FROM Employees WHERE BirthDate BETWEEN "1960-0-1" AND "1970-0-1";

SELECT * FROM Employees WHERE LastName LIKE "Fuller";

SELECT * FROM Employees WHERE LastName LIKE "%ller";

SELECT * FROM Employees WHERE LastName LIKE "F%";

SELECT * FROM Employees WHERE LastName LIKE "%U%";

SELECT * FROM Employees WHERE LastName LIKE "F____r";

SELECT * FROM Employees WHERE LastName LIKE "_u____";

SELECT * FROM Employees WHERE LastName LIKE "_u__%";

SELECT * FROM Products WHERE ProductName IS NULL ORDER BY ProductName ASC;

SELECT * FROM Products WHERE ProductName IS NOT NULL ORDER BY ProductName ASC;

SELECT * FROM Products WHERE SupplierID IN (3, 4, 5);

SELECT * FROM Employees WHERE LastName IN ("Fuller", "King");

-- Funciones de agregación
SELECT SUM(price) AS Suma_total FROM Products;

SELECT COUNT(FirstName) AS Cantidad_de_nombres FROM Employees;

SELECT AVG(Price) AS Promedio FROM Products;

SELECT ROUND(AVG(Price), 2) AS Promedio FROM Products;

SELECT ProductName, MIN(Price) FROM Products;

SELECT ProductName, MAX(Price) FROM Products;

-- GROUP BY
SELECT SupplierID,  ROUND(AVG(Price), 2) AS Promedio FROM Products GROUP BY SupplierID;

SELECT SupplierID,  ROUND(AVG(Price), 2) AS Promedio FROM Products GROUP BY SupplierID HAVING Promedio > 40; -- HAVING es el WHERE de los grupos. Filtra grupos.

SELECT SupplierID,  ROUND(AVG(Price), 2) AS Promedio FROM Products WHERE SupplierID IN (3, 4, 5) GROUP BY SupplierID HAVING Promedio > 40; -- Igual se puede usar el WHERE antes de agrupar.

-- Sub Queries
SELECT ProductID, Quantity, (SELECT ProductName FROM Products WHERE OrderDetails.ProductID = ProductID) AS Product_name FROM OrderDetails;

SELECT ProductID, 
		(SELECT ProductName FROM Products WHERE OD.ProductID = ProductID) AS Product_name,
		SUM(Quantity) AS Total_vendido, 
		(SELECT Price FROM Products WHERE OD.ProductID = ProductID) AS Price, 
		(SUM(Quantity) * (SELECT Price FROM Products WHERE OD.ProductID = ProductID)) AS Total_recaudado 
FROM [OrderDetails] OD 
GROUP BY ProductID 
ORDER BY Total_recaudado DESC;

SELECT ProductID, 
		(SELECT ProductName FROM Products WHERE OD.ProductID = ProductID) AS Product_name,
		SUM(Quantity) AS Total_vendido, 
		(SUM(Quantity) * (SELECT Price FROM Products WHERE OD.ProductID = ProductID)) AS Total_recaudado 
FROM [OrderDetails] OD 
WHERE (SELECT Price FROM Products WHERE OD.ProductID = ProductID)
GROUP BY ProductID 
ORDER BY Total_recaudado DESC;

SELECT Product_name, Total_vendido FROM (
SELECT ProductID, 
		(SELECT ProductName FROM Products WHERE OD.ProductID = ProductID) AS Product_name,
		SUM(Quantity) AS Total_vendido, 
		(SUM(Quantity) * (SELECT Price FROM Products WHERE OD.ProductID = ProductID)) AS Total_recaudado 
FROM [OrderDetails] OD 
WHERE (SELECT Price FROM Products WHERE OD.ProductID = ProductID)
GROUP BY ProductID 
ORDER BY Total_recaudado DESC)
WHERE Total_vendido > 300;

SELECT FirstName, LastName,
		(SELECT SUM(OD.Quantity) FROM [Orders] O, [OrderDetails] OD WHERE O.EmployeeID = E.EmployeeID AND OD.OrderID = O.OrderID) AS Unidades_vendidas
FROM [Employees] E
WHERE Unidades_vendidas > (SELECT AVG(Unidades_totales) FROM (
	SELECT (SELECT SUM(OD.Quantity) FROM [Orders] O, [OrderDetails] OD WHERE O.EmployeeID = E2.EmployeeID AND OD.OrderID = O.OrderID) AS Unidades_totales FROM [Employees] E2
GROUP BY E2.EmployeeID
));

-- JOINS
SELECT * FROM Employees E, Orders O WHERE E.EmployeeID = O.EmployeeID; -- old, implicit JOIN

SELECT * FROM Employees E CROSS JOIN Orders O; -- This is the above query without the WHERE clause. All posible combinations, not really useful.

SELECT * FROM Employees E INNER JOIN Orders O ON E.EmployeeID = O.EmployeeID; -- Actual way of making the query. The default JOIN.

-- Side quest: Create a new table and populate it.
CREATE TABLE "Rewards" (
"RewardID" INTEGER,
"EmployeeID" INTEGER,
"Reward" INTEGER,
"Month" TEXT,
PRIMARY KEY("RewardID" AUTOINCREMENT)
);

INSERT INTO Rewards (EmployeeID, Reward, Month) VALUES
(3, 200, "January"),
(2, 180, "February"),
(5, 250, "March"),
(1, 280, "April"),
(null, null, "May");

SELECT * FROM Rewards;

-- Back to JOINs
SELECT FirstName, Reward, Month FROM Employees E
INNER JOIN Rewards R ON E.EmployeeID = R.EmployeeID;

SELECT FirstName, Reward, Month FROM Employees E
LEFT JOIN Rewards R ON E.EmployeeID = R.EmployeeID; -- All Employees and the reward they earned. If they didn't, fill with null.

SELECT FirstName, Reward, Month FROM Employees E
RIGHT JOIN Rewards R ON E.EmployeeID = R.EmployeeID; --  RIGHT JOINs are not supported in SQLite3 but...

SELECT FirstName, Reward, Month FROM Rewards R
LEFT JOIN Employees E ON E.EmployeeID = R.EmployeeID; -- The result would be this.

-- FULL OUTER JOIN
SELECT * FROM Employees E FULL OUTER JOIN Rewards R
ON E.EmployeeID = R.EmployeeID -- Not supported by SQLite3. It represents the sum of a LEFT JOIN and RIGHT JOIN. Therefore:

SELECT FirstName, Reward, Month FROM Employees E
LEFT JOIN Rewards R ON E.EmployeeID = R.EmployeeID
UNION
SELECT FirstName, Reward, Month FROM Rewards R
LEFT JOIN Employees E ON E.EmployeeID = R.EmployeeID;

-- Notes on UNION: The rows from both sources must have the same number of columns and the same data types. UNION doesn't return duplicates. UNION ALL does.


-- INDEX
SELECT * FROM Products WHERE ProductName = "Chais";

CREATE INDEX name ON Products (ProductName); -- Allows null values and duplicates

CREATE UNIQUE INDEX name ON Employees (FirstName) -- Creates a CONSTRAINT: Doesn't allow duplicates. Trying to insert an employee with the same name as another should fail.

CREATE UNIQUE INDEX fullname ON Employees (FirstName, LastName) -- Composite INDEX. Can't have two John Smith employed, bro. F.

-- Notes: PRIMARY KEYs are usually indexes by default. It is recomended to INDEX FOREIGN KEYs. Indexing not always works to make queries faster.

SELECT * FROM OrderDetails OD
JOIN Orders O
WHERE OD.Quantity > 10 AND O.OrderDate > "1996-07-04"; -- Without indexing runs in 26ms, with the indexes it runs in 427ms. Much worse.

CREATE INDEX idx_orderDetails_quantity ON OrderDetails (Quantity);
CREATE INDEX idx_orders_orderDate ON Orders (OrderDate);

DROP INDEX idx_orderDetails_quantity;
DROP INDEX idx_orders_orderDate;

-- VIEW
CREATE VIEW Simplified_Products AS
SELECT ProductID, ProductName, Price FROM Products WHERE ProductID > 20 ORDER BY ProductID;

SELECT * FROM Simplified_Products;

DROP VIEW IF EXISTS Simplified_Products;

-- MISC EXAMPLES
SELECT ProductName, SUM(Price * Quantity) AS Revenue
FROM OrderDetails OD
JOIN Products P ON P.ProductID = OD.ProductID
GROUP BY OD.ProductID
ORDER BY Revenue DESC
LIMIT 1; -- Best selling Product by total revenue

SELECT FirstName || " " || LastName AS Employee, COUNT(*) AS Total
FROM Orders O
JOIN Employees E ON E.EmployeeID = O.EmployeeID
GROUP BY O.EmployeeID
ORDER BY Total DESC
LIMIT 3; -- Top 3 Employees by sales