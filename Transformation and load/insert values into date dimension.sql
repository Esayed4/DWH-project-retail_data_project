delete from dim_date
drop table us_holidays
CREATE TABLE dbo.us_holidays (
    holiday_month INT NOT NULL,
    holiday_day   INT NOT NULL,
    holiday_name  NVARCHAR(100),
    CONSTRAINT PK_us_holidays PRIMARY KEY (holiday_month, holiday_day)
);

-- Insert fixed-date holidays
INSERT INTO dbo.us_holidays VALUES
(1, 1, 'New Year''s Day'),
(7, 4, 'Independence Day'),
(11, 11, 'Veterans Day'),
(12, 25, 'Christmas Day'),

(1, 20, 'Martin Luther King Jr. Day'),  -- 3rd Monday in Jan, here just example
(2, 17, 'Presidents'' Day'),           -- 3rd Monday in Feb
(5, 26, 'Memorial Day'),               -- last Monday in May
(9, 1, 'Labor Day'),                   -- 1st Monday in Sep
(10, 13, 'Columbus Day'),              -- 2nd Monday in Oct
(11, 27, 'Thanksgiving Day');          -- 4th Thursday in Nov



CREATE OR ALTER PROCEDURE LoadDimDateFromOrders
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH AllDates AS (
        SELECT order_date AS d FROM staging.Orders WHERE order_date IS NOT NULL
        UNION
        SELECT order_approved_date FROM staging.Orders WHERE order_approved_date IS NOT NULL
        UNION
        SELECT pickup_date FROM staging.Orders WHERE pickup_date IS NOT NULL
        UNION
        SELECT delivered_date FROM staging.Orders WHERE delivered_date IS NOT NULL
        UNION
        SELECT estimated_time_delivery FROM staging.Orders WHERE estimated_time_delivery IS NOT NULL
    )
    INSERT INTO dim_date (
        date_id, full_date, year, month, day, hour, minute,
        quarter, week_of_year, week_of_month, day_of_year,
        day_of_month, day_of_week, is_holiday
    )
    SELECT DISTINCT
        CONVERT(BIGINT, FORMAT(d,'yyyyMMddHHmm')) AS date_id,
        CAST(d AS DATE) AS full_date,
        YEAR(d), MONTH(d), DAY(d),
        DATEPART(HOUR, d), DATEPART(MINUTE, d),
        DATEPART(QUARTER, d),
        DATEPART(WEEK, d),
        (DAY(d)+6)/7,
        DATEPART(DAYOFYEAR, d),
        DAY(d),
        DATEPART(WEEKDAY, d),
        CASE WHEN EXISTS (
            SELECT 1 FROM dbo.us_holidays h
            WHERE h.holiday_month = MONTH(d)
              AND h.holiday_day   = DAY(d)
        ) THEN 1 ELSE 0 END
    FROM AllDates a
    WHERE NOT EXISTS (
        SELECT 1 FROM dim_date dd
        WHERE dd.date_id = CONVERT(BIGINT, FORMAT(a.d,'yyyyMMddHHmm'))
    );
END
GO


EXEC LoadDimDateFromOrders;

SELECT TOP 20 full_date, year, month, day, is_holiday
FROM dim_date
WHERE is_holiday = 1
ORDER BY full_date;