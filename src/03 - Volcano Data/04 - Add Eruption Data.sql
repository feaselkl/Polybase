-- Adds historical eruption events from a second SQL Server instance via the
-- PolyBase sqlserver:// connector.

USE [Scratch];
GO

OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.external_tables
    WHERE name = N'Eruption'
)
BEGIN
    -- Three-part name in LOCATION targets ExternalExample.dbo.Eruption on the
    -- remote instance.
    CREATE EXTERNAL TABLE dbo.Eruption
    (
        EruptionId        INT NOT NULL,
        VolcanoName       NVARCHAR(150) NOT NULL,
        Country           NVARCHAR(75)  NOT NULL,
        Region            NVARCHAR(150) NULL,
        Latitude          FLOAT         NULL,
        Longitude         FLOAT         NULL,
        Elevation         INT           NULL,
        Morphology        NVARCHAR(75)  NULL,
        EventYear         INT           NOT NULL,
        EventMonth        TINYINT       NULL,
        EventDay          TINYINT       NULL,
        VEI               TINYINT       NULL,
        DeathsTotal       INT           NULL,
        InjuriesTotal     INT           NULL,
        HousesDestroyed   INT           NULL,
        DamageMillionsUSD FLOAT         NULL,
        Agent             VARCHAR(20)   NULL,
        TimeErupt         VARCHAR(10)   NULL,
        [Status]          VARCHAR(50)   NULL
    )
    WITH
    (
        DATA_SOURCE = RemoteSQLServer,
        LOCATION    = 'ExternalExample.dbo.Eruption'
    );
END
GO

-- The shape: SELECT against the remote like a regular table.
SELECT TOP (10) *
FROM dbo.Eruption
ORDER BY EventYear DESC;
GO

-- Filter pushes down to the remote. With PUSHDOWN = ON on the data source,
-- the WHERE clause executes there, not here.
SELECT
    VolcanoName,
    Country,
    EventYear,
    VEI,
    DeathsTotal
FROM dbo.Eruption
WHERE VEI >= 5
ORDER BY EventYear DESC;
GO

-- The four-source payoff query. Cosmos volcanoes + Blob country data +
-- PostgreSQL type descriptions + remote SQL Server eruption history,
-- joined in T-SQL. One statement, four engines, two protocols (TDS, ODBC),
-- and a MongoDB wire flavor on top.
SELECT
    v.VolcanoName,
    v.Country,
    v.Type,
    vt.[description] AS TypeDescription,
    c.GDPPerCapita,
    e.EventYear,
    e.VEI,
    e.DeathsTotal,
    e.DamageMillionsUSD
FROM dbo.Volcano v
    LEFT OUTER JOIN dbo.CountryData c
        ON v.Country = c.Country
    LEFT OUTER JOIN dbo.VolcanoType vt
        ON v.Type = vt.[type]
    INNER JOIN dbo.Eruption e
        ON v.VolcanoName = e.VolcanoName
WHERE e.VEI >= 4
ORDER BY
    e.DeathsTotal DESC,
    e.EventYear DESC;
GO

-- A more analytical question: which volcano types have caused the most
-- recorded fatalities, weighted by the average GDP per capita of the
-- countries they're in?
SELECT
    v.Type,
    vt.[description] AS TypeDescription,
    COUNT(*) AS RecordedEruptions,
    SUM(ISNULL(e.DeathsTotal, 0)) AS TotalDeaths,
    AVG(c.GDPPerCapita) AS AvgGDPPerCapita
FROM dbo.Volcano v
    LEFT OUTER JOIN dbo.CountryData c
        ON v.Country = c.Country
    LEFT OUTER JOIN dbo.VolcanoType vt
        ON v.Type = vt.[type]
    INNER JOIN dbo.Eruption e
        ON v.VolcanoName = e.VolcanoName
GROUP BY
    v.Type,
    vt.[description]
HAVING SUM(ISNULL(e.DeathsTotal, 0)) > 0
ORDER BY TotalDeaths DESC;
GO
