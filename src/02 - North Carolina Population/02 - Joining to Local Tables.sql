-- The point of data virtualization isn't just to read external data, but also
-- joining external data to your existing tables. This script wires up
-- a small reference hierarchy in the local database and joins the
-- Cities external table to it.

USE Scratch;
GO

-- Two of North Carolina's metros: the Triangle (Raleigh-Durham-Chapel Hill)
-- and the Triad (Greensboro-Winston-Salem-High Point). Plain SQL tables.
IF (OBJECT_ID('dbo.PopulationCenter') IS NULL)
BEGIN
    CREATE TABLE dbo.PopulationCenter
    (
        PopulationCenterName VARCHAR(30) NOT NULL PRIMARY KEY CLUSTERED
    );

    INSERT INTO dbo.PopulationCenter (PopulationCenterName)
    VALUES
        ('Triangle'),
        ('Triad');
END
GO

IF (OBJECT_ID('dbo.CityPopulationCenter') IS NULL)
BEGIN
    CREATE TABLE dbo.CityPopulationCenter
    (
        CityName             VARCHAR(120) NOT NULL,
        PopulationCenterName VARCHAR(30) NOT NULL,
        CONSTRAINT [PK_CityPopulationCenter]
            PRIMARY KEY CLUSTERED (CityName, PopulationCenterName),
        CONSTRAINT [FK_CityPopulationCenter_PopulationCenter]
            FOREIGN KEY (PopulationCenterName)
            REFERENCES dbo.PopulationCenter(PopulationCenterName)
    );

    -- Names match cities in NorthCarolinaPopulationCities.csv.
    INSERT INTO dbo.CityPopulationCenter (CityName, PopulationCenterName)
    VALUES
        ('Burlington',     'Triad'),
        ('Greensboro',     'Triad'),
        ('High Point',     'Triad'),
        ('Winston-Salem',  'Triad'),
        ('Apex',           'Triangle'),
        ('Cary',           'Triangle'),
        ('Chapel Hill',    'Triangle'),
        ('Durham',         'Triangle'),
        ('Raleigh',        'Triangle');
END
GO

-- External table on the left, local table on the right, regular T-SQL JOIN.
SELECT
    ncp.GeographicArea AS City,
    cpc.PopulationCenterName,
    ncp.Population
FROM dbo.NorthCarolinaPopulationCities ncp
    INNER JOIN dbo.CityPopulationCenter cpc
        ON ncp.GeographicArea = cpc.CityName
WHERE ncp.[Year] = 2024
ORDER BY ncp.Population DESC;
GO

-- Aggregations across the boundary work too: roll cities up to metros.
SELECT
    cpc.PopulationCenterName,
    ncp.[Year],
    SUM(ncp.Population) AS MetroPopulation
FROM dbo.NorthCarolinaPopulationCities ncp
    INNER JOIN dbo.CityPopulationCenter cpc
        ON ncp.GeographicArea = cpc.CityName
GROUP BY
    cpc.PopulationCenterName,
    ncp.[Year]
ORDER BY
    ncp.[Year],
    cpc.PopulationCenterName;
GO

-- Year-over-year growth for each metro.
WITH MetroByYear AS
(
    SELECT
        cpc.PopulationCenterName,
        ncp.[Year],
        SUM(ncp.Population) AS MetroPopulation
    FROM dbo.NorthCarolinaPopulationCities ncp
        INNER JOIN dbo.CityPopulationCenter cpc
            ON ncp.GeographicArea = cpc.CityName
    GROUP BY
        cpc.PopulationCenterName,
        ncp.[Year]
)
SELECT
    PopulationCenterName,
    [Year],
    MetroPopulation,
    MetroPopulation - LAG(MetroPopulation) OVER
        (PARTITION BY PopulationCenterName ORDER BY [Year]) AS YoYChange
FROM MetroByYear
ORDER BY
    PopulationCenterName,
    [Year];
GO
