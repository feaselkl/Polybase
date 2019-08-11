USE ForensicAccounting
GO
CREATE TABLE dbo.Calendar
(
    DateKey INT NOT NULL,
    [Date] DATE NOT NULL,
    [Day] TINYINT NOT NULL,
    DayOfWeek TINYINT NOT NULL,
    DayName VARCHAR(10) NOT NULL,
    IsWeekend BIT NOT NULL,
    DayOfWeekInMonth TINYINT NOT NULL,
    CalendarDayOfYear SMALLINT NOT NULL,
    WeekOfMonth TINYINT NOT NULL,
    CalendarWeekOfYear TINYINT NOT NULL,
    CalendarMonth TINYINT NOT NULL,
    MonthName VARCHAR(10) NOT NULL,
    CalendarQuarter TINYINT NOT NULL,
    CalendarQuarterName CHAR(2) NOT NULL,
    CalendarYear INT NOT NULL,
    FirstDayOfMonth DATE NOT NULL,
    LastDayOfMonth DATE NOT NULL,
    FirstDayOfWeek DATE NOT NULL,
    LastDayOfWeek DATE NOT NULL,
    FirstDayOfQuarter DATE NOT NULL,
    LastDayOfQuarter DATE NOT NULL,
    CalendarFirstDayOfYear DATE NOT NULL,
    CalendarLastDayOfYear DATE NOT NULL,
    FirstDayOfNextMonth DATE NOT NULL,
    CalendarFirstDayOfNextYear DATE NOT NULL,
    FiscalDayOfYear SMALLINT NOT NULL,
    FiscalWeekOfYear TINYINT NOT NULL,
    FiscalMonth TINYINT NOT NULL,
    FiscalQuarter TINYINT NOT NULL,
    FiscalQuarterName CHAR(2) NOT NULL,
    FiscalYear INT NOT NULL,
    FiscalFirstDayOfYear DATE NOT NULL,
    FiscalLastDayOfYear DATE NOT NULL,
    FiscalFirstDayOfNextYear DATE NOT NULL,
    CONSTRAINT [PK_Calendar] PRIMARY KEY CLUSTERED([Date]),
    CONSTRAINT [UKC_Calendar] UNIQUE(DateKey)
);
GO

DECLARE
    @StartDate DATE = '18000101',
    @NumberOfYears INT = 726;
 
--Remove ambiguity with regional settings.
SET DATEFIRST 7;
SET DATEFORMAT mdy;
SET LANGUAGE US_ENGLISH;
 
DECLARE
    @EndDate DATE = DATEADD(YEAR, @NumberOfYears, @StartDate);
 
WITH
L0 AS(SELECT 1 AS c UNION ALL SELECT 1),
L1 AS(SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),
L2 AS(SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),
L3 AS(SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),
L4 AS(SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),
L5 AS(SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B),
Nums AS(SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 0)) AS n FROM L5)
INSERT INTO dbo.Calendar
(
    DateKey,
    [Date],
    [Day],
    [DayOfWeek],
    [DayName],
    IsWeekend,
    DayOfWeekInMonth,
    CalendarDayOfYear,
    WeekOfMonth,
    CalendarWeekOfYear,
    CalendarMonth,
    [MonthName],
    CalendarQuarter,
    CalendarQuarterName,
    CalendarYear,
    FirstDayOfMonth,
    LastDayOfMonth,
    FirstDayOfWeek,
    LastDayOfWeek,
    FirstDayOfQuarter,
    LastDayOfQuarter,
    CalendarFirstDayOfYear,
    CalendarLastDayOfYear,
    FirstDayOfNextMonth,
    CalendarFirstDayOfNextYear,
    FiscalDayOfYear,
    FiscalWeekOfYear,
    FiscalMonth,
    FiscalQuarter,
    FiscalQuarterName,
    FiscalYear,
    FiscalFirstDayOfYear,
    FiscalLastDayOfYear,
    FiscalFirstDayOfNextYear
)
SELECT
    CAST(D.DateKey AS INT) AS DateKey,
    D.[DATE] AS [Date],
    CAST(D.[day] AS TINYINT) AS [day],
    CAST(d.[dayofweek] AS TINYINT) AS [DayOfWeek],
    CAST(DATENAME(WEEKDAY, d.[Date]) AS VARCHAR(10)) AS [DayName],
    CAST(CASE WHEN [DayOfWeek] IN (1, 7) THEN 1 ELSE 0 END AS BIT) AS [IsWeekend],
    CAST(ROW_NUMBER() OVER (PARTITION BY d.FirstOfMonth, d.[DayOfWeek] ORDER BY d.[Date]) AS TINYINT) AS DayOfWeekInMonth,
    CAST(DATEPART(DAYOFYEAR, d.[Date]) AS SMALLINT) AS CalendarDayOfYear,
    CAST(DENSE_RANK() OVER (PARTITION BY d.[year], d.[month] ORDER BY d.[week]) AS TINYINT) AS WeekOfMonth,
    CAST(d.[week] AS TINYINT) AS CalendarWeekOfYear,
    CAST(d.[month] AS TINYINT) AS CalendarMonth,
    CAST(d.[monthname] AS VARCHAR(10)) AS [MonthName],
    CAST(d.[quarter] AS TINYINT) AS CalendarQuarter,
    CONCAT('Q', d.[quarter]) AS CalendarQuarterName,
    d.[year] AS CalendarYear,
    d.FirstOfMonth AS FirstDayOfMonth,
    MAX(d.[Date]) OVER (PARTITION BY d.[year], d.[month]) AS LastDayOfMonth,
    MIN(d.[Date]) OVER (PARTITION BY d.[year], d.[week]) AS FirstDayOfWeek,
    MAX(d.[Date]) OVER (PARTITION BY d.[year], d.[week]) AS LastDayOfWeek,
    MIN(d.[Date]) OVER (PARTITION BY d.[year], d.[quarter]) AS FirstDayOfQuarter,
    MAX(d.[Date]) OVER (PARTITION BY d.[year], d.[quarter]) AS LastDayOfQuarter,
    FirstOfYear AS CalendarFirstDayOfYear,
    MAX(d.[Date]) OVER (PARTITION BY d.[year]) AS CalendarLastDayOfYear,
    DATEADD(MONTH, 1, d.FirstOfMonth) AS FirstDayOfNextMonth,
    DATEADD(YEAR, 1, d.FirstOfYear) AS CalendarFirstDayOfNextYear,
    DATEDIFF(DAY, fy.FYStart, d.[Date]) + 1 AS FiscalDayOfYear,
    DATEDIFF(WEEK, fy.FYStart, d.[Date]) + 1 AS FiscalWeekOfYear,
    CASE
        WHEN d.[month] >= 7 THEN d.[month] - 6
        ELSE d.[month] + 6
    END AS FiscalMonth,
    CASE d.[quarter]
        WHEN 1 THEN 3
        WHEN 2 THEN 4
        WHEN 3 THEN 1
        WHEN 4 THEN 2
    END AS FiscalQuarter,
    CONCAT('Q', CASE d.[quarter]
        WHEN 1 THEN 3
        WHEN 2 THEN 4
        WHEN 3 THEN 1
        WHEN 4 THEN 2
    END) AS FiscalQuarterName,
    YEAR(fy.FYStart) AS FiscalYear,
    fy.FYStart AS FiscalFirstDayOfYear,
    MAX(d.[Date]) OVER (PARTITION BY fy.FYStart) AS FiscalLastDayOfYear,
    DATEADD(YEAR, 1, fy.FYStart) AS FiscalFirstDayOfNextYear
FROM Nums n
    CROSS APPLY
    (
        SELECT
            DATEADD(DAY, n - 1, @StartDate) AS [DATE]
    ) d0
    CROSS APPLY
    (
        SELECT
            d0.[date],
            DATEPART(DAY, d0.[date]) AS [day],
            DATEPART(MONTH, d0.[date]) AS [month],
            CONVERT(DATE, DATEADD(MONTH, DATEDIFF(MONTH, 0, d0.[date]), 0)) AS FirstOfMonth,
            DATENAME(MONTH, d0.[date]) AS [MonthName],
            DATEPART(WEEK, d0.[date]) AS [week],
            DATEPART(WEEKDAY, d0.[date]) AS [DayOfWeek],
            DATEPART(QUARTER, d0.[date]) AS [quarter],
            DATEPART(YEAR, d0.[date]) AS [year],
            CONVERT(DATE, DATEADD(YEAR, DATEDIFF(YEAR, 0, d0.[date]), 0)) AS FirstOfYear,
            CONVERT(CHAR(8), d0.[date], 112) AS DateKey
    ) d
    CROSS APPLY
    (
        SELECT
            --Fiscal year starts July 1.
            FYStart = DATEADD(MONTH, -6, DATEADD(YEAR, DATEDIFF(YEAR, 0, DATEADD(MONTH, 6, d.[date])), 0))
    ) fy
    CROSS APPLY
    (
        SELECT
            FYyear = YEAR(fy.FYStart)
    ) fyint
WHERE
    n.n <= DATEDIFF(DAY, @StartDate, @EndDate)
ORDER BY
    [date] OPTION (MAXDOP 1);
GO
