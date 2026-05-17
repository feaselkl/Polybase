-- Adds country-level enrichment from a CIA World Factbook CSV stored on
-- Azure Blob Storage.

USE [Scratch];
GO

OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

IF (OBJECT_ID('dbo.CountryData') IS NULL)
BEGIN
    CREATE EXTERNAL TABLE dbo.CountryData
    (
        Country                        NVARCHAR(75) NOT NULL,
        Area                           INT NULL,
        BirthRate                      DECIMAL(6,2) NULL,
        CurrentAccountBalance          BIGINT NULL,
        DeathRate                      DECIMAL(7,2) NULL,
        ExternalDebt                   BIGINT NULL,
        ElectrictyConsumption          BIGINT NULL,
        ElectrictyProduction           BIGINT NULL,
        Exports                        BIGINT NULL,
        GDP                            BIGINT NULL,
        GDPPerCapita                   DECIMAL(8,2) NULL,
        RealGrowthRate                 DECIMAL(6,2) NULL,
        HivAidsPrevalenceRate          DECIMAL(5,2) NULL,
        HivAidsDeaths                  INT NULL,
        HivAidsPopulation              INT NULL,
        HighwaysKm                     BIGINT NULL,
        Imports                        BIGINT NULL,
        IndustrialProductionGrowthRate DECIMAL(6,2) NULL,
        InfantMortalityRate            DECIMAL(5,2) NULL,
        InflationRate                  DECIMAL(10,2) NULL,
        InternetHosts                  INT NULL,
        InternetUsers                  BIGINT NULL,
        InvestmentPercent              DECIMAL(5,2) NULL,
        LaborForce                     BIGINT NULL,
        LifeExpectancy                 DECIMAL(5,2) NULL,
        MilitaryExpenditures           BIGINT NULL,
        MilitaryExpenditurePercent     DECIMAL(5,2) NULL,
        NaturalGasConsumption          BIGINT NULL,
        NaturalGasExports              BIGINT NULL,
        NaturalGasImports              BIGINT NULL,
        NaturalGasProduction           BIGINT NULL,
        NaturalGasProvedReserves       BIGINT NULL,
        OilConsumption                 BIGINT NULL,
        OilExports                     BIGINT NULL,
        OilImports                     BIGINT NULL,
        OilProduction                  BIGINT NULL,
        OilProvedReserves              BIGINT NULL,
        Population                     BIGINT NULL,
        PublicDebtPercent              DECIMAL(5,2) NULL,
        RailwaysKm                     BIGINT NULL,
        ReservesForeignExchangeAndGold BIGINT NULL,
        Telephones                     BIGINT NULL,
        MobilePhones                   BIGINT NULL,
        TotalFertilityRate             DECIMAL(4,2) NULL,
        UnemploymentRate               DECIMAL(5,2) NULL
    )
    WITH
    (
        DATA_SOURCE  = AzureBlobStorage,
        LOCATION     = N'factbook.csv',
        FILE_FORMAT  = SemiColonFileFormat,
        REJECT_TYPE  = VALUE,
        REJECT_VALUE = 5
    );
END
GO

-- Sanity check: SELECT * over the Blob CSV.
SELECT TOP (10)
    cd.Country,
    cd.Area,
    cd.GDP,
    cd.Population,
    cd.LifeExpectancy
FROM dbo.CountryData cd
ORDER BY cd.Population DESC;
GO

-- Two-source federated query: Cosmos volcanoes joined to Blob country data.
SELECT
    v.VolcanoName,
    v.Country,
    v.Elevation,
    c.Population,
    c.GDPPerCapita,
    c.LifeExpectancy
FROM dbo.Volcano v
    LEFT OUTER JOIN dbo.CountryData c
        ON v.Country = c.Country
ORDER BY v.Elevation DESC;
GO

-- Volcanoes per country, sorted by GDP per capita. Mixes a Cosmos
-- aggregate with a Blob lookup.
SELECT
    v.Country,
    COUNT(*) AS VolcanoCount,
    AVG(v.Elevation * 1.0) AS AvgElevationMeters,
    MAX(c.GDPPerCapita) AS GDPPerCapita
FROM dbo.Volcano v
    INNER JOIN dbo.CountryData c
        ON v.Country = c.Country
GROUP BY v.Country
ORDER BY GDPPerCapita DESC;
GO
