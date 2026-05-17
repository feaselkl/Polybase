-- This script adds two new datasets:
--   * County-level population (CSV) on ADLS Gen2
--   * County-level median household income (Parquet) on a local
--     S3-compatible object store

USE Scratch;
GO

OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

-- County-level population: same shape as the cities CSV (GeographicArea,
-- Year, Population) but rolled up to the 100 NC counties.
IF (OBJECT_ID('dbo.NorthCarolinaPopulation', 'ET') IS NULL)
BEGIN
    CREATE EXTERNAL TABLE dbo.NorthCarolinaPopulation
    (
        GeographicArea VARCHAR(120) NOT NULL,
        [Year]         INT NOT NULL,
        Population     INT NOT NULL
    )
    WITH
    (
        DATA_SOURCE  = AzureDataLakeStorage,
        LOCATION     = N'Census/NorthCarolinaPopulation.csv',
        FILE_FORMAT  = CsvFileFormatWithHeader,
        REJECT_TYPE  = VALUE,
        REJECT_VALUE = 5
    );
END
GO

-- Sanity check: 100 counties x 6 years.
SELECT
    [Year],
    COUNT(*)        AS CountyCount,
    SUM(Population) AS StatePopulation
FROM dbo.NorthCarolinaPopulation
GROUP BY [Year]
ORDER BY [Year];
GO

-- Median household income from the Census ACS, this time on the local
-- S3-compatible store.
IF (OBJECT_ID('dbo.NCCountyMedianHouseholdIncome', 'ET') IS NULL)
BEGIN
    CREATE EXTERNAL TABLE dbo.NCCountyMedianHouseholdIncome
    (
        StateFIPS             VARCHAR(2)  NOT NULL,
        CountyFIPS            VARCHAR(3)  NOT NULL,
        GeographicArea        VARCHAR(120) NOT NULL,
        [Year]                INT NOT NULL,
        MedianHouseholdIncome BIGINT NOT NULL
    )
    WITH
    (
        DATA_SOURCE  = S3Storage,
        -- Leading slash + bucket name: PolyBase's S3 connector expects the
        -- bucket as the first path segment when the EDS LOCATION is
        -- 's3://host:port/'. Without the leading slash, the URL builder
        -- fails before any network call.
        LOCATION     = N'/ncpop/Census/NCCountyMedianHouseholdIncome.parquet',
        FILE_FORMAT  = ParquetFileFormat,
        REJECT_TYPE  = VALUE,
        REJECT_VALUE = 5
    );
END
GO

-- Quick look.
SELECT TOP (10) *
FROM dbo.NCCountyMedianHouseholdIncome
ORDER BY MedianHouseholdIncome DESC;
GO

-- Join across an ADLS-backed external table and an S3-backed external table.
-- Highest median household income for each county in 2023, with population.
SELECT
    p.GeographicArea AS County,
    p.[Year],
    p.Population,
    i.MedianHouseholdIncome
FROM dbo.NorthCarolinaPopulation p
    INNER JOIN dbo.NCCountyMedianHouseholdIncome i
        ON p.GeographicArea = i.GeographicArea
        AND p.[Year]        = i.[Year]
WHERE p.[Year] = 2023
ORDER BY i.MedianHouseholdIncome DESC;
GO

-- A simple analytic question: which counties have grown population AND
-- income between 2020 and 2023?
WITH ByYear AS
(
    SELECT
        p.GeographicArea AS County,
        p.[Year],
        p.Population,
        i.MedianHouseholdIncome
    FROM dbo.NorthCarolinaPopulation p
        INNER JOIN dbo.NCCountyMedianHouseholdIncome i
            ON p.GeographicArea = i.GeographicArea
            AND p.[Year]        = i.[Year]
    WHERE p.[Year] IN (2020, 2023)
)
SELECT
    a.County,
    a.Population AS Population2020,
    b.Population AS Population2023,
    b.Population - a.Population AS PopulationDelta,
    a.MedianHouseholdIncome AS Income2020,
    b.MedianHouseholdIncome AS Income2023,
    b.MedianHouseholdIncome - a.MedianHouseholdIncome AS IncomeDelta
FROM ByYear a
    INNER JOIN ByYear b
        ON a.County = b.County
WHERE
    a.[Year] = 2020
    AND b.[Year] = 2023
    AND b.Population > a.Population
    AND b.MedianHouseholdIncome > a.MedianHouseholdIncome
ORDER BY PopulationDelta DESC;
GO
