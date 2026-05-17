-- The flip side of CREATE EXTERNAL TABLE: CREATE EXTERNAL TABLE AS SELECT
-- (CETAS) writes the result of a federated query out to Parquet files on
-- Azure Blob Storage, ADLS, or S3.
--
-- Prerequisites already covered earlier in the demo flow:
--   - sp_configure 'allow polybase export', 1  (set by infra/docker init)
--   - dbo.Volcano, dbo.CountryData, dbo.VolcanoType are populated
--   - AzureBlobStorage and ParquetFileFormat are owned by 01 - External Objects/
--
-- Re-run note: dropping a CETAS external table does NOT delete the underlying
-- Parquet files. Either delete blob://<container>/exports/volcanoes/ in Azure
-- before re-running, or change LOCATION below.

USE [Scratch];
GO

-- Idempotent cleanup of the export's table-side handle. The underlying files
-- on blob storage are NOT removed by this drop; that is a manual step.
IF OBJECT_ID('dbo.VolcanoExport', 'ET') IS NOT NULL
    DROP EXTERNAL TABLE dbo.VolcanoExport;
GO

-- The payoff: one statement turns the federated volcano query into Parquet on Azure Blob.
CREATE EXTERNAL TABLE dbo.VolcanoExport
WITH
(
    DATA_SOURCE = AzureBlobStorage,
    LOCATION    = 'exports/volcanoes/',
    FILE_FORMAT = ParquetFileFormat
)
AS
SELECT
    v._id,
    v.VolcanoName,
    v.Country,
    c.Area,
    c.GDP,
    c.GDPPerCapita,
    c.Population,
    c.LifeExpectancy,
    v.Region,
    v.Location_Type AS LocationType,
    v.Elevation,
    v.Type,
    vt.[description] AS TypeDescription,
    v.Status,
    v.LastEruption
FROM dbo.Volcano v
    LEFT OUTER JOIN dbo.CountryData c
        ON v.Country = c.Country
    LEFT OUTER JOIN dbo.VolcanoType vt
        ON v.Type = vt.[type];
GO

-- The new external table reads back the files we just produced.
-- (Anyone else with credentials to that blob path can read them too — this
-- is how PolyBase becomes a one-shot publishing tool, not just a query tool.)
SELECT TOP (10) *
FROM dbo.VolcanoExport
ORDER BY Elevation DESC;
GO

SELECT COUNT(*) AS RowsExported
FROM dbo.VolcanoExport;
GO
