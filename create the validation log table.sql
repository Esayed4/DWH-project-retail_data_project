CREATE TABLE  staging.validation_log (
    validation_id INT IDENTITY(1,1) PRIMARY KEY,
    table_name NVARCHAR(128),
    column_name NVARCHAR(128),
    validation_type NVARCHAR(50),
    result NVARCHAR(200),
    validation_date DATETIME DEFAULT GETDATE()
);

CREATE  PROCEDURE ValidateStagingTable
    @TableName NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OLTP_Count INT;
    DECLARE @Staging_Count INT;
    DECLARE @SQL NVARCHAR(MAX);
    DECLARE @ColumnName NVARCHAR(128);
    DECLARE @NullCount INT;

    -------------------------
    -- 1️⃣ Row Count Check
    -------------------------
    SET @SQL = N'SELECT @Count_OUT = COUNT(*) FROM online_store.dbo.' + QUOTENAME(@TableName);
    EXEC sp_executesql @SQL, N'@Count_OUT INT OUTPUT', @Count_OUT=@OLTP_Count OUTPUT;

    SET @SQL = N'SELECT @Count_OUT = COUNT(*) FROM DWH_project_retail_data_project.staging.' + QUOTENAME(@TableName);
    EXEC sp_executesql @SQL, N'@Count_OUT INT OUTPUT', @Count_OUT=@Staging_Count OUTPUT;

    INSERT INTO staging.validation_log (table_name, column_name, validation_type, result)
    VALUES (@TableName, NULL, 'Row Count',
            CASE WHEN @OLTP_Count = @Staging_Count THEN 'OK'
                 ELSE 'Mismatch: OLTP=' + CAST(@OLTP_Count AS NVARCHAR(10)) +
                      ', Staging=' + CAST(@Staging_Count AS NVARCHAR(10)) END);

    -------------------------
    -- 2️⃣ Data Type Mismatch Check
    -------------------------
    INSERT INTO staging.validation_log (table_name, column_name, validation_type, result)
    SELECT s.TABLE_NAME, s.COLUMN_NAME, 'DataType Check',
           'Staging=' + s.DATA_TYPE + ', OLTP=' + o.DATA_TYPE
    FROM DWH_project_retail_data_project.INFORMATION_SCHEMA.COLUMNS s
    JOIN online_store.INFORMATION_SCHEMA.COLUMNS o
      ON s.COLUMN_NAME = o.COLUMN_NAME 
     AND s.TABLE_NAME = @TableName
     AND o.TABLE_NAME = @TableName
    WHERE s.DATA_TYPE <> o.DATA_TYPE;

end

EXEC ValidateStagingTable 'Products';
EXEC ValidateStagingTable 'Users';
EXEC ValidateStagingTable 'Sellers';
EXEC ValidateStagingTable 'Orders';
EXEC ValidateStagingTable 'Payments';
EXEC ValidateStagingTable 'Order_Items';
EXEC ValidateStagingTable 'Feedbacks';

select * from staging.validation_log