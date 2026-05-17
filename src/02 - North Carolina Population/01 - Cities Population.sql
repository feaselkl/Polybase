USE Scratch;
GO

OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

IF (OBJECT_ID('dbo.NorthCarolinaPopulationCities', 'ET') IS NULL)
BEGIN
    CREATE EXTERNAL TABLE dbo.NorthCarolinaPopulationCities
    (
        GeographicArea VARCHAR(120) NOT NULL,
        [Year]         INT NOT NULL,
        Population     INT NOT NULL
    )
    WITH
    (
        DATA_SOURCE  = AzureBlobStorage,
        LOCATION     = N'Census/NorthCarolinaPopulationCities.csv',
        FILE_FORMAT  = CsvFileFormatWithHeader,
        REJECT_TYPE  = VALUE,
        REJECT_VALUE = 5
    );
END
GO

-- The external table behaves just like a regular SQL Server table.
-- SELECT * works.
SELECT TOP (20) *
FROM dbo.NorthCarolinaPopulationCities
ORDER BY
    Population DESC,
    GeographicArea;
GO

-- Filters work as expected.
SELECT
    GeographicArea,
    Population
FROM dbo.NorthCarolinaPopulationCities
WHERE [Year] = 2024
ORDER BY Population DESC;
GO

-- Aggregations work as expected.
SELECT
    [Year],
    COUNT(*) AS PlaceCount,
    SUM(Population) AS TotalUrbanPopulation
FROM dbo.NorthCarolinaPopulationCities
GROUP BY [Year]
ORDER BY [Year];
GO
