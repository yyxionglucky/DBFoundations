--*************************************************************************--
-- Title: Assignment06
-- Author: Yingying Xiong
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2022-08-17,Yingying Xiong,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_YingyingXiong')
	 Begin 
	  Alter Database [Assignment06DB_YingyingXiong] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_YingyingXiong;
	 End
	Create Database Assignment06DB_YingyingXiong;
End Try
Begin Catch
	Print Error_Number();
End Catch
GO
Use Assignment06DB_YingyingXiong;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
GO

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
GO

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
GO

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
GO

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
GO

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
GO

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
GO

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
GO

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
GO

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
GO

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
GO

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
GO

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
GO
Select * From Products;
GO
Select * From Employees;
GO
Select * From Inventories;
GO

/********************************* Questions and Answers *********************************/
print
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'
GO
-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
CREATE VIEW vCategories 
WITH SCHEMABINDING AS
SELECT CategoryID, CategoryName FROM dbo.Categories;
GO
CREATE VIEW vProducts
WITH SCHEMABINDING AS
SELECT ProductID,ProductName,CategoryID, UnitPrice FROM dbo.Products;
GO
CREATE VIEW vEmployees
WITH SCHEMABINDING AS
SELECT EmployeeID,EmployeeFirstName,EmployeeLastName,ManagerID from dbo.Employees;
GO
CREATE VIEW vInventories 
WITH SCHEMABINDING AS
SELECT InventoryID,InventoryDate,EmployeeID,ProductID, Count from dbo.Inventories;
GO
-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
Deny SELECT ON Categories to Public;
Deny SELECT On Products to Public;
Deny SELECT On Employees to Public;
Deny SELECT On Inventories to Public;

Grant SELECT On vCategories to Public;
Grant SELECT On vProducts to Public;
Grant SELECT On vEmployees to Public;
Grant SELECT On vInventories to Public;
GO
-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

CREATE VIEW vProductsByCategories AS
SELECT TOP 1000000
C.CategoryName, P.ProductName, P.UnitPrice
FROM dbo.Categories AS C
JOIN dbo.Products AS P ON C.CategoryID = P.CategoryID
ORDER BY CategoryName,ProductName;
GO
-- Here is an example of some rows selected from the view:
-- CategoryName ProductName       UnitPrice
-- Beverages    Chai              18.00
-- Beverages    Chang             19.00
-- Beverages    Chartreuse verte  18.00


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!
CREATE VIEW vInventoriesByProductsByDates AS
SELECT TOP 1000000
 P.ProductName,I.InventoryDate,I.Count
FROM dbo.Products as P
JOIN dbo.Inventories AS I ON P.ProductID = I.ProductID
ORDER BY ProductName, InventoryDate, Count;
GO
-- Here is an example of some rows selected from the view:
-- ProductName	  InventoryDate	Count
-- Alice Mutton	  2017-01-01	  0
-- Alice Mutton	  2017-02-01	  10
-- Alice Mutton	  2017-03-01	  20
-- Aniseed Syrup	2017-01-01	  13
-- Aniseed Syrup	2017-02-01	  23
-- Aniseed Syrup	2017-03-01	  33


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!
CREATE VIEW vInventoriesByEmployeesByDates AS
SELECT distinct TOP 1000000
 I.InventoryDate, E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
FROM dbo.Inventories AS I
JOIN dbo.Employees as E on I.EmployeeID = E. EmployeeID
ORDER BY InventoryDate;
GO
-- Here is are the rows selected from the view:
-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
CREATE VIEW vInventoriesByProductsByCategories AS
SELECT TOP 1000000
 C.CategoryName, P.ProductName, I.InventoryDate, I.Count
FROM dbo.Products AS P
JOIN dbo.Categories AS C  ON P. CategoryID = C.CategoryID
JOIN dbo.Inventories AS I ON P.ProductID = I.ProductID
ORDER BY CategoryName, ProductName,InventoryDate, Count;
GO
-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- CategoryName	ProductName	InventoryDate	Count
-- Beverages	  Chai	      2017-01-01	  39
-- Beverages	  Chai	      2017-02-01	  49
-- Beverages	  Chai	      2017-03-01	  59
-- Beverages	  Chang	      2017-01-01	  17
-- Beverages	  Chang	      2017-02-01	  27
-- Beverages	  Chang	      2017-03-01	  37


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!
CREATE VIEW vInventoriesByProductsByEmployees AS
SELECT TOP 1000000
 C.CategoryName, P.ProductName, I.InventoryDate, I.Count, EmployeeName =  E.EmployeeFirstName + ' ' + E.EmployeeLastName
FROM dbo.Products AS P
JOIN dbo.Categories AS C  ON P. CategoryID = C.CategoryID
JOIN dbo.Inventories AS I ON P. ProductID = I. ProductID
JOIN dbo.Employees AS E ON E.EmployeeID = I.EmployeeID
ORDER BY InventoryDate, CategoryName,ProductName,EmployeeName;
GO
-- Here is an example of some rows selected from the view:
-- CategoryName	ProductName	        InventoryDate	Count	EmployeeName
-- Beverages	  Chai	              2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	              2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chartreuse verte	  2017-01-01	  69	  Steven Buchanan
-- Beverages	  C�te de Blaye	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Guaran� Fant�stica	2017-01-01	  20	  Steven Buchanan
-- Beverages	  Ipoh Coffee	        2017-01-01	  17	  Steven Buchanan
-- Beverages	  Lakkalik��ri	      2017-01-01	  57	  Steven Buchanan

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
CREATE VIEW vInventoriesForChaiAndChangByEmployees AS
SELECT TOP 1000000
 C.CategoryName, P.ProductName, I.InventoryDate, I.Count, [EmployeeName] =  E.EmployeeFirstName + ' ' + E.EmployeeLastName
FROM (SELECT*FROM Products WHERE ProductName in ('Chai','Chang')) AS P
JOIN dbo.Categories AS C  ON P.CategoryID = C.CategoryID
JOIN dbo.Inventories AS I ON P. ProductID = I. ProductID
JOIN dbo.Employees AS E ON E.EmployeeID = I.EmployeeID
ORDER BY InventoryDate, CategoryName,ProductName;
GO
-- Here are the rows selected from the view:

-- CategoryName	ProductName	InventoryDate	Count	EmployeeName
-- Beverages	  Chai	      2017-01-01	  39	  Steven Buchanan
-- Beverages	  Chang	      2017-01-01	  17	  Steven Buchanan
-- Beverages	  Chai	      2017-02-01	  49	  Robert King
-- Beverages	  Chang	      2017-02-01	  27	  Robert King
-- Beverages	  Chai	      2017-03-01	  59	  Anne Dodsworth
-- Beverages	  Chang	      2017-03-01	  37	  Anne Dodsworth


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
CREATE VIEW vEmployeesByManager AS
SELECT TOP 1000000
[Manager] = IIF(IsNull(M.EmployeeId, 0) = 0, 'General Manager',M.EmployeeFirstName + ' ' + M.EmployeeLastName ),
[Employee] =  E.EmployeeFirstName + ' ' + E.EmployeeLastName
FROM dbo.Employees AS E
JOIN dbo.Employees AS M  On M.EmployeeID = E.ManagerID
ORDER BY Manager;
GO
-- Here are teh rows selected from the view:
-- Manager	        Employee
-- Andrew Fuller	  Andrew Fuller
-- Andrew Fuller	  Janet Leverling
-- Andrew Fuller	  Laura Callahan
-- Andrew Fuller	  Margaret Peacock
-- Andrew Fuller	  Nancy Davolio
-- Andrew Fuller	  Steven Buchanan
-- Steven Buchanan	Anne Dodsworth
-- Steven Buchanan	Michael Suyama
-- Steven Buchanan	Robert King


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

CREATE VIEW vInventoriesByProductsByCategoriesByEmployees AS
SELECT TOP 1000000
 C.CategoryID AS CategoryID, C.CategoryName, P.ProductID, P.ProductName, P.UnitPrice AS UnitPrice,
  I.InventoryID AS InventoryID, I.InventoryDate AS InventoryDate, I.Count AS Count, E.EmployeeID AS EmployeeID, E.EmployeeFirstName + ' ' + E.EmployeeLastName AS Employee
FROM dbo.vInventories AS I JOIN vProducts AS P ON I.ProductID = P.ProductID
JOIN dbo.vCategories AS C ON C.CategoryID = P.CategoryID
JOIN dbo.vEmployees AS E ON E.EmployeeID = I.EmployeeID
JOIN dbo.vEmployees AS M ON E.ManagerID = M.EmployeeID
ORDER BY C.CategoryID, P.ProductID, InventoryID, Employee
GO
-- Here is an example of some rows selected from the view:
-- CategoryID	  CategoryName	ProductID	ProductName	        UnitPrice	InventoryID	InventoryDate	Count	EmployeeID	Employee
-- 1	          Beverages	    1	        Chai	              18.00	    1	          2017-01-01	  39	  5	          Steven Buchanan
-- 1	          Beverages	    1	        Chai	              18.00	    78	        2017-02-01	  49	  7	          Robert King
-- 1	          Beverages	    1	        Chai	              18.00	    155	        2017-03-01	  59	  9	          Anne Dodsworth
-- 1	          Beverages	    2	        Chang	              19.00	    2	          2017-01-01	  17	  5	          Steven Buchanan
-- 1	          Beverages	    2	        Chang	              19.00	    79	        2017-02-01	  27	  7	          Robert King
-- 1	          Beverages	    2	        Chang	              19.00	    156	        2017-03-01	  37	  9	          Anne Dodsworth
-- 1	          Beverages	    24	      Guaran� Fant�stica	4.50	    24	        2017-01-01	  20	  5	          Steven Buchanan
-- 1	          Beverages	    24	      Guaran� Fant�stica	4.50	    101	        2017-02-01	  30	  7	          Robert King
-- 1	          Beverages	    24	      Guaran� Fant�stica	4.50	    178	        2017-03-01	  40	  9	          Anne Dodsworth
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    34	        2017-01-01	  111	  5	          Steven Buchanan
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    111	        2017-02-01	  121	  7	          Robert King
-- 1	          Beverages	    34	      Sasquatch Ale	      14.00	    188	        2017-03-01	  131	  9	          Anne Dodsworth


-- Test your Views (NOTE: You must change the names to match yours as needed!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/
