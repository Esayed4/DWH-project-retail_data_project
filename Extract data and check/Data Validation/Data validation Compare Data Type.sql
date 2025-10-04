CREATE OR ALTER PROCEDURE checkDataTypeMismatch
    @TableName NVARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT s.COLUMN_NAME, s.DATA_TYPE AS StagingType, o.DATA_TYPE AS OLTPType
    FROM DWH_project_retail_data_project.INFORMATION_SCHEMA.COLUMNS s
    JOIN online_store.INFORMATION_SCHEMA.COLUMNS o
      ON s.COLUMN_NAME = o.COLUMN_NAME
      AND s.TABLE_NAME = @TableName
      AND o.TABLE_NAME = @TableName
    WHERE s.DATA_TYPE <> o.DATA_TYPE;
END
GO


EXEC checkDataTypeMismatch 'Products' ;
EXEC checkDataTypeMismatch 'Users' ;
EXEC checkDataTypeMismatch 'Sellers' ;
EXEC checkDataTypeMismatch 'Orders' ;
EXEC checkDataTypeMismatch 'Payments' ;
EXEC checkDataTypeMismatch 'Order_Items' ;
EXEC checkDataTypeMismatch 'Feedbacks' ;