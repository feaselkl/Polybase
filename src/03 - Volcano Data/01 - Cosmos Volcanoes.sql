-- Open the volcano demo by attaching SQL Server to a Cosmos DB collection.

USE [Scratch];
GO

OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

-- A first attempt at the external table includes Volcano_Coordinates,
-- which Cosmos stores as a [longitude, latitude] array.
IF NOT EXISTS
(
    SELECT 1 FROM sys.external_tables
    WHERE name = N'VolcanoTest'
)
BEGIN
    CREATE EXTERNAL TABLE dbo.VolcanoTest
    (
        _id                 NVARCHAR(100)  NOT NULL,
        VolcanoName         NVARCHAR(100)  NOT NULL,
        Country             NVARCHAR(100)  NULL,
        Region              NVARCHAR(100)  NULL,
        Location_Type       NVARCHAR(100)  NULL,
        Elevation           INT            NULL,
        Type                NVARCHAR(100)  NULL,
        Status              NVARCHAR(200)  NULL,
        LastEruption        NVARCHAR(300)  NULL,
        Volcano_Coordinates FLOAT
    )
    WITH
    (
        DATA_SOURCE = CosmosDB,
        LOCATION    = 'PolyBaseTest.Volcano'
    );
END
GO

-- First quirk: SELECT * returns more rows than there are volcanoes.
-- The MongoDB connector flattens the coordinate array, so each volcano
-- shows up once per element ([longitude, latitude] = two rows).
SELECT TOP (20) *
FROM dbo.VolcanoTest
ORDER BY VolcanoName, Volcano_Coordinates;
GO

-- Side-by-side: 1500-ish volcanoes, but the row count is roughly double.
SELECT
    COUNT(DISTINCT _id) AS VolcanoCount,
    COUNT(Volcano_Coordinates) AS [RowCount]
FROM dbo.VolcanoTest;
GO

-- Workaround #1: drop the coordinate column from the projection and
-- DISTINCT the rest. Works, but loses the coordinates entirely.
SELECT DISTINCT
    _id,
    VolcanoName,
    Country,
    Region,
    Elevation,
    Type,
    Status,
    LastEruption
FROM dbo.VolcanoTest;
GO

-- Workaround #2: STRING_AGG the coordinates into a single comma-separated
-- value per volcano. Keeps the data, sidesteps the flattening.
-- NOTE: STRING_AGG() over external tables only became supported in SQL Server
-- 2025. For older versions, load the data into a temp table first.

SELECT
    v._id,
    v.VolcanoName,
    v.Country,
    v.Region,
    v.Location_Type AS LocationType,
    STRING_AGG(CAST(v.Volcano_Coordinates AS VARCHAR(50)), ',') AS Coordinates,
    v.Elevation,
    v.Type,
    v.Status,
    v.LastEruption
FROM dbo.VolcanoTest v
GROUP BY
    v._id,
    v.VolcanoName,
    v.Country,
    v.Region,
    v.Location_Type,
    v.Elevation,
    v.Type,
    v.Status,
    v.LastEruption
ORDER BY v.Elevation ASC;
GO


-- Workaround #3: a second external table that simply omits the
-- coordinate column. The MongoDB connector silently skips it and we
-- get one row per volcano without any post-processing. This is the
-- shape we'll use for the rest of the demo.
IF NOT EXISTS
(
    SELECT 1 FROM sys.external_tables
    WHERE name = N'Volcano'
)
BEGIN
    CREATE EXTERNAL TABLE dbo.Volcano
    (
        _id           NVARCHAR(100) NOT NULL,
        VolcanoName   NVARCHAR(100) NOT NULL,
        Country       NVARCHAR(100) NULL,
        Region        NVARCHAR(100) NULL,
        Location_Type NVARCHAR(100) NULL,
        Elevation     INT NULL,
        Type          NVARCHAR(100) NULL,
        Status        NVARCHAR(200) NULL,
        LastEruption  NVARCHAR(300) NULL
    )
    WITH
    (
        DATA_SOURCE = CosmosDB,
        LOCATION    = 'PolyBaseTest.Volcano'
    );
END
GO

-- Clean: one row per volcano, ready to join.
SELECT TOP (20) *
FROM dbo.Volcano
ORDER BY Elevation DESC;
GO
