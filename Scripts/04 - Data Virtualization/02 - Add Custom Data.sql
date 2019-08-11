USE [Scratch]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO
-- Try a simple execution.
EXEC dbo.Volcano_GetVolcanoData;
GO
-- Extend with blob storage-stored country data.
IF NOT EXISTS
(
    SELECT 1
    FROM sys.external_file_formats e
    WHERE  
        e.name = N'SemiColonFileFormat'
)
BEGIN
    CREATE EXTERNAL FILE FORMAT SemiColonFileFormat WITH
    (
        FORMAT_TYPE = DELIMITEDTEXT,
        FORMAT_OPTIONS
        (
            FIELD_TERMINATOR = N';',
            USE_TYPE_DEFAULT = False,
            STRING_DELIMITER = '"',
            ENCODING = 'UTF8'
        )
    );
END
GO
drop external table dbo.countrydata
IF (OBJECT_ID('dbo.CountryData') IS NULL)
BEGIN
	CREATE EXTERNAL TABLE dbo.CountryData
	(
		Country NVARCHAR(75) NOT NULL,
		Area INT NULL,
		BirthRate DECIMAL(6,2) NULL,
		CurrentAccountBalance BIGINT NULL,
		DeathRate DECIMAL(7,2) NULL,
		ExternalDebt BIGINT NULL,
		ElectrictyConsumption BIGINT NULL,
		ElectrictyProduction BIGINT NULL,
		Exports BIGINT NULL,
		GDP BIGINT NULL,
		GDPPerCapita DECIMAL(8,2) NULL,
		RealGrowthRate DECIMAL(6,2) NULL,
		HivAidsPrevalenceRate DECIMAL (5,2) NULL,
		HivAidsDeaths INT NULL,
		HivAidsPopulation INT NULL,
		HighwaysKm BIGINT NULL,
		Imports BIGINT NULL,
		IndustrialProductionGrowthRate DECIMAL(6,2) NULL,
		InfantMortalityRate DECIMAL(5,2) NULL,
		InflationRate DECIMAL(10,2) NULL,
		InternetHosts INT NULL,
		InternetUsers BIGINT NULL,
		InvestmentPercent DECIMAL(5,2) NULL,
		LaborForce BIGINT NULL,
		LifeExpectancy DECIMAL(5,2) NULL,
		MilitaryExpenditures BIGINT NULL,
		MilitaryExpenditurePercent DECIMAL(5,2) NULL,
		NaturalGasConsumption BIGINT NULL,
		NaturalGasExports BIGINT NULL,
		NaturalGasImports BIGINT NULL,
		NaturalGasProduction BIGINT NULL,
		NaturalGasProvedReserves BIGINT NULL,
		OilConsumption BIGINT NULL,
		OilExports BIGINT NULL,
		OilImports BIGINT NULL,
		OilProduction BIGINT NULL,
		OilProvedReserves BIGINT NULL,
		Population BIGINT NULL,
		PublicDebtPercent DECIMAL(5,2) NULL,
		RailwaysKm BIGINT NULL,
		ReservesForeignExchangeAndGold BIGINT NULL,
		Telephones BIGINT NULL,
		MobilePhones BIGINT NULL,
		TotalFertilityRate DECIMAL(4,2) NULL,
		UnemploymentRate DECIMAL(5,2) NULL
	)
	WITH
	(
		LOCATION = N'factbook.csv',
		DATA_SOURCE = AzureNCPopBlob,
		FILE_FORMAT = SemiColonFileFormat,
		REJECT_TYPE = VALUE,
		REJECT_VALUE = 5
	);
END
GO
-- Now extend our procedure with this additional data.
CREATE OR ALTER PROCEDURE dbo.Volcano_GetVolcanoData
AS
BEGIN
	SELECT *
	INTO #Volcanoes
	FROM dbo.Volcano;

	SELECT
		_id,
		v.VolcanoName,
		v.Country,
		c.Area,
		c.GDP,
		c.GDPPerCapita,
		c.RealGrowthRate,
		c.Population,
		c.LaborForce,
		c.LifeExpectancy,
		v.Region,
		v.Location_Type AS LocationType,
		STRING_AGG(v.Volcano_Coordinates, ',') AS Coordinates,
		v.Elevation,
		v.Type,
		v.Status,
		v.LastEruption
	FROM #Volcanoes v
		LEFT OUTER JOIN dbo.CountryData c
			ON v.Country = c.Country
	GROUP BY
		_id,
		v.VolcanoName,
		v.Country,
		c.Area,
		c.GDP,
		c.GDPPerCapita,
		c.RealGrowthRate,
		c.Population,
		c.LaborForce,
		c.LifeExpectancy,
		v.Region,
		v.Location_Type,
		v.Elevation,
		v.Type,
		v.Status,
		v.LastEruption
	ORDER BY
		v.Elevation ASC;
END
GO
EXEC dbo.Volcano_GetVolcanoData;
GO
