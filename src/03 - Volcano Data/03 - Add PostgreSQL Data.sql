-- Adds the volcano_type description lookup from the docker-compose
-- Postgres sidecar.

USE [Scratch];
GO

OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.external_tables
    WHERE name = N'VolcanoType'
)
BEGIN
    -- Lowercase identifiers match what is in Postgres.
    -- LOCATION format for PolyBase's ODBC connector is exactly three parts:
    --   <database>.<schema>.<table>
    -- The first segment becomes `database=...` in the ODBC connection
    -- string; the remaining two identify the table. The schema `public`
    -- is reserved in PolyBase's identifier parser, so it must be wrapped
    -- in brackets — without them you get error 105076 ("could not be
    -- parsed"). Two-part LOCATION is also rejected (error 105121,
    -- "expected 3").
    CREATE EXTERNAL TABLE dbo.VolcanoType
    (
        [type]        NVARCHAR(100),
        [description] NVARCHAR(2000)
    )
    WITH
    (
        DATA_SOURCE = Postgres,
        LOCATION    = 'volcanodemo.[public].volcano_type'
    );
END
GO

-- The lookup itself: a small reference table on the Postgres side.
SELECT *
FROM dbo.VolcanoType
ORDER BY [type];
GO

-- The payoff query: Cosmos DB + Azure Blob CSV + PostgreSQL, joined in T-SQL.
SELECT
    v.VolcanoName,
    v.Country,
    v.Elevation,
    v.Type,
    vt.[description] AS TypeDescription,
    v.Status,
    v.LastEruption,
    c.Population,
    c.GDPPerCapita
FROM dbo.Volcano v
    LEFT OUTER JOIN dbo.CountryData c
        ON v.Country = c.Country
    LEFT OUTER JOIN dbo.VolcanoType vt
        ON v.Type = vt.[type]
ORDER BY v.Elevation DESC;
GO
