-- Data validation check after Extract

CREATE PROCEDURE CheckRowCount
    @TableName NVARCHAR(128)
AS
BEGIN
    DECLARE @OLTP_Count INT;
    DECLARE @Extract_Count INT;
    DECLARE @SQL NVARCHAR(MAX);

    -- Get row count from OLTP table
    SET @SQL = 'SELECT @Count = COUNT(*) FROM online_store.dbo.' + QUOTENAME(@TableName);
    EXEC sp_executesql @SQL, N'@Count INT OUTPUT', @Count=@OLTP_Count OUTPUT;

    -- Get row count from Staging table
    SET @SQL = 'SELECT @Count = COUNT(*) FROM DWH_project_retail_data_project.staging.' + QUOTENAME(@TableName);
    EXEC sp_executesql @SQL, N'@Count INT OUTPUT', @Count=@Extract_Count OUTPUT;

    -- Compare counts
    IF @OLTP_Count = @Extract_Count
        PRINT 'Table ' + @TableName + ' is OK';
    ELSE
        PRINT 'Table ' + @TableName + ' is NOT OK in Row Count';
END
GO

EXEC CheckRowCount 'Products' ;
EXEC CheckRowCount 'Users' ;
EXEC CheckRowCount 'Sellers' ;
EXEC CheckRowCount 'Orders' ;
EXEC CheckRowCount 'Payments' ;
EXEC CheckRowCount 'Order_Items' ;
EXEC CheckRowCount 'Feedbacks' ;




