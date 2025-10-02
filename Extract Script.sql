USE DWH_project_retail_data_project; 
GO

-- Create Staging Schema if not exists
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'staging') 
    EXEC('CREATE SCHEMA staging'); 
GO

-- Drop staging tables if exist
IF OBJECT_ID('staging.Products') IS NOT NULL DROP TABLE staging.Products;
IF OBJECT_ID('staging.Users') IS NOT NULL DROP TABLE staging.Users;
IF OBJECT_ID('staging.Sellers') IS NOT NULL DROP TABLE staging.Sellers;
IF OBJECT_ID('staging.Orders') IS NOT NULL DROP TABLE staging.Orders;
IF OBJECT_ID('staging.Payments') IS NOT NULL DROP TABLE staging.Payments;
IF OBJECT_ID('staging.Order_Items') IS NOT NULL DROP TABLE staging.Order_Items;
IF OBJECT_ID('staging.Feedbacks') IS NOT NULL DROP TABLE staging.Feedbacks;
GO

-- Create Staging Tables (clone OLTP schema)
SELECT * INTO staging.Products FROM online_store.dbo.Products WHERE 1=0;
SELECT * INTO staging.Users FROM online_store.dbo.Users WHERE 1=0;
SELECT * INTO staging.Sellers FROM online_store.dbo.Sellers WHERE 1=0;
SELECT * INTO staging.Orders FROM online_store.dbo.Orders WHERE 1=0;
SELECT * INTO staging.Payments FROM online_store.dbo.Payments WHERE 1=0;
SELECT * INTO staging.Order_Items FROM online_store.dbo.Order_Items WHERE 1=0;
SELECT * INTO staging.Feedbacks FROM online_store.dbo.Feedbacks WHERE 1=0;
GO

-- Extract (Load from OLTP into staging)
TRUNCATE TABLE staging.Products; 
INSERT INTO staging.Products SELECT * FROM online_store.dbo.Products;

TRUNCATE TABLE staging.Users; 
INSERT INTO staging.Users SELECT * FROM online_store.dbo.Users;

TRUNCATE TABLE staging.Sellers; 
INSERT INTO staging.Sellers SELECT * FROM online_store.dbo.Sellers;

TRUNCATE TABLE staging.Orders; 
INSERT INTO staging.Orders SELECT * FROM online_store.dbo.Orders;

TRUNCATE TABLE staging.Payments; 
INSERT INTO staging.Payments SELECT * FROM online_store.dbo.Payments;

TRUNCATE TABLE staging.Order_Items; 
INSERT INTO staging.Order_Items SELECT * FROM online_store.dbo.Order_Items;

TRUNCATE TABLE staging.Feedbacks; 
INSERT INTO staging.Feedbacks SELECT * FROM online_store.dbo.Feedbacks;
GO
