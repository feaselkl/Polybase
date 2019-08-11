USE [Scratch]
GO
-- Create external statistics based on an implicit full scan.
IF NOT EXISTS
(
    SELECT 1
    FROM sys.stats s
    WHERE
        s.name = N'sNorthCarolinaPopulation_Name'
)
BEGIN
    CREATE STATISTICS [sNorthCarolinaPopulation_Name] ON [dbo].[NorthCarolinaPopulation]
    (
            [Name]
    );
END
GO

-- External statistics look the same as regular statistics based on sys.stats.
SELECT
    s.*
FROM sys.stats s
    INNER JOIN sys.tables t
        ON s.object_id = t.object_id;
GO

DBCC SHOW_STATISTICS ('dbo.NorthCarolinaPopulation', 'sNorthCarolinaPopulation_Name')
GO

-- Create external statistics based on an explicit full scan.
IF NOT EXISTS
(
    SELECT 1
    FROM sys.stats s
    WHERE
        s.name = N'sNorthCarolinaPopulation_County'
)
BEGIN
    CREATE STATISTICS [sNorthCarolinaPopulation_County] ON [dbo].[NorthCarolinaPopulation]
    (
            [County]
    ) WITH FULLSCAN;
END
GO

-- Create external statistics based on a sample.
IF NOT EXISTS
(
    SELECT 1
    FROM sys.stats s
    WHERE
        s.name = N'sNorthCarolinaPopulation_SumLev'
)
BEGIN
    CREATE STATISTICS [sNorthCarolinaPopulation_SumLev] ON [dbo].[NorthCarolinaPopulation]
    (
            [SumLev]
    ) WITH SAMPLE 40 PERCENT;
END
GO

-- Create external statistics based on a sample for multiple columns.
IF NOT EXISTS
(
    SELECT 1
    FROM sys.stats s
    WHERE
        s.name = N'sNorthCarolinaPopulation_Year_Name'
)
BEGIN
    CREATE STATISTICS [sNorthCarolinaPopulation_Year_Name] ON [dbo].[NorthCarolinaPopulation]
    (
            [Year],
            [Name]
    ) WITH SAMPLE 40 PERCENT;
END
GO

-- Updating statistics will fail.
UPDATE STATISTICS [dbo].[NorthCarolinaPopulation]
(
    [sNorthCarolinaPopulation_Year_Name]
) WITH FULLSCAN;

-- Sampling from a SQL Server table will fail.
CREATE STATISTICS [sEmployee_FirstName] ON [ELT].[Employee]
(
    FirstName
) WITH SAMPLE 40 PERCENT;