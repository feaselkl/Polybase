-- The final piece: BLS county-level unemployment from ADLS Gen2 as
-- a Parquet external table. Joined back to county population and
-- median household income for a county-by-county economic snapshot.

USE Scratch;
GO

OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

IF (OBJECT_ID('dbo.NCCountyUnemployment', 'ET') IS NULL)
BEGIN
    CREATE EXTERNAL TABLE dbo.NCCountyUnemployment
    (
        StateFIPS        VARCHAR(2)  NOT NULL,
        CountyFIPS       VARCHAR(3)  NOT NULL,
        GeographicArea   VARCHAR(120) NOT NULL,
        [Year]           INT NOT NULL,
        LaborForce       BIGINT NOT NULL,
        Employed         BIGINT NOT NULL,
        Unemployed       BIGINT NOT NULL,
        UnemploymentRate FLOAT NOT NULL
    )
    WITH
    (
        DATA_SOURCE  = AzureDataLakeStorage,
        LOCATION     = N'BLS/NCCountyUnemployment.parquet',
        FILE_FORMAT  = ParquetFileFormat,
        REJECT_TYPE  = VALUE,
        REJECT_VALUE = 5
    );
END
GO

-- Highest unemployment counties for the most recent year.
SELECT TOP 10
    GeographicArea,
    [Year],
    LaborForce,
    UnemploymentRate
FROM dbo.NCCountyUnemployment
WHERE [Year] = 2024
ORDER BY UnemploymentRate DESC;
GO

-- Connecting multiple data sources together.
SELECT
    p.GeographicArea AS County,
    p.Population,
    i.MedianHouseholdIncome,
    u.UnemploymentRate,
    u.LaborForce
FROM dbo.NorthCarolinaPopulation p
    INNER JOIN dbo.NCCountyMedianHouseholdIncome i
        ON p.GeographicArea = i.GeographicArea
        AND p.[Year]        = i.[Year]
    INNER JOIN dbo.NCCountyUnemployment u
        ON p.GeographicArea = u.GeographicArea
        AND p.[Year]        = u.[Year]
WHERE p.[Year] = 2023
ORDER BY i.MedianHouseholdIncome DESC;
GO

-- A fun one to close: rank counties on each metric and find the counties
-- that score in the top quartile across all three (high income, low
-- unemployment, growing population).
WITH CountySnapshot AS
(
    SELECT
        p2023.GeographicArea AS County,
        p2023.Population - p2020.Population AS PopulationGrowth,
        i.MedianHouseholdIncome,
        u.UnemploymentRate
    FROM dbo.NorthCarolinaPopulation p2020
        INNER JOIN dbo.NorthCarolinaPopulation p2023
            ON p2020.GeographicArea = p2023.GeographicArea
            AND p2020.[Year] = 2020 AND p2023.[Year] = 2023
        INNER JOIN dbo.NCCountyMedianHouseholdIncome i
            ON p2023.GeographicArea = i.GeographicArea
            AND i.[Year] = 2023
        INNER JOIN dbo.NCCountyUnemployment u
            ON p2023.GeographicArea = u.GeographicArea
            AND u.[Year] = 2023
),
Ranked AS
(
    SELECT
        County,
        PopulationGrowth,
        MedianHouseholdIncome,
        UnemploymentRate,
        NTILE(4) OVER (ORDER BY PopulationGrowth DESC)         AS GrowthQuartile,
        NTILE(4) OVER (ORDER BY MedianHouseholdIncome DESC)    AS IncomeQuartile,
        NTILE(4) OVER (ORDER BY UnemploymentRate ASC)          AS LowUnemploymentQuartile
    FROM CountySnapshot
)
SELECT *
FROM Ranked
WHERE GrowthQuartile = 1
    AND IncomeQuartile = 1
    AND LowUnemploymentQuartile = 1
ORDER BY MedianHouseholdIncome DESC;
GO
