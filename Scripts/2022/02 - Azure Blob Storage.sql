USE Scratch
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO
IF NOT EXISTS
(
	SELECT *
	FROM sys.database_scoped_credentials
	WHERE
		name = N'AzureStorageCredential'
)
BEGIN
	CREATE DATABASE SCOPED CREDENTIAL AzureStorageCredential
	WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
	SECRET = '<YOUR SECRET>';
END
GO
IF NOT EXISTS
(
	SELECT 1
	FROM sys.external_data_sources s
	WHERE
		s.name = N'AzureNCPopBlob'
)
BEGIN
	CREATE EXTERNAL DATA SOURCE AzureNCPopBlob WITH
	(
		LOCATION = 'abs://ncpop@cspolybaseblob.blob.core.windows.net',
		CREDENTIAL = AzureStorageCredential
	);
END
GO
IF NOT EXISTS
(
    SELECT 1
    FROM sys.external_file_formats e
    WHERE  
        e.name = N'CsvFileFormat'
)
BEGIN
    CREATE EXTERNAL FILE FORMAT CsvFileFormatWithHeader WITH
    (
        FORMAT_TYPE = DELIMITEDTEXT,
        FORMAT_OPTIONS
        (
            FIELD_TERMINATOR = N',',
            USE_TYPE_DEFAULT = True,
            STRING_DELIMITER = '"',
            ENCODING = 'UTF8'
        )
    );
END
GO
IF NOT EXISTS
(
    SELECT 1
    FROM sys.external_file_formats e
    WHERE  
        e.name = N'CsvFileFormatWithHeader'
)
BEGIN
    CREATE EXTERNAL FILE FORMAT CsvFileFormatWithHeader WITH
    (
        FORMAT_TYPE = DELIMITEDTEXT,
        FORMAT_OPTIONS
        (
            FIELD_TERMINATOR = N',',
			FIRST_ROW = 2,
            USE_TYPE_DEFAULT = True,
            STRING_DELIMITER = '"',
            ENCODING = 'UTF8'
        )
    );
END
GO
IF (OBJECT_ID('dbo.NorthCarolinaPopulation') IS NULL)
BEGIN
	CREATE EXTERNAL TABLE dbo.NorthCarolinaPopulation
	(
		SumLev INT NOT NULL,
		County INT NOT NULL,
		Place INT NOT NULL,
		IsPrimaryGeography BIT NOT NULL,
		[Name] VARCHAR(120) NOT NULL,
		PopulationType VARCHAR(20) NOT NULL,
		Year INT NOT NULL,
		Population INT NOT NULL
	)
	WITH
	(
        DATA_SOURCE = AzureNCPopBlob,
		LOCATION = N'Census/NorthCarolinaPopulation.csv',
		FILE_FORMAT = CsvFileFormatWithHeader,
		REJECT_TYPE = VALUE,
		REJECT_VALUE = 5
	);
END
GO

--Quick SELECT * to ensure that data loads as expected.
--Note 13607 rows returned but CSV has 13611 (including one header)
SELECT
    ncp.SumLev AS SummaryLevel,
    ncp.County,
    ncp.Place,
    ncp.IsPrimaryGeography,
    ncp.Name,
    ncp.PopulationType,
    ncp.Year,
    ncp.Population
FROM dbo.NorthCarolinaPopulation ncp;
GO

--Filters work as you'd expect:  full town population estimates for 2017.
SELECT
    ncp.Name,
    ncp.Population
FROM dbo.NorthCarolinaPopulation ncp
WHERE
    ncp.Year = 2017
    AND ncp.PopulationType = 'POPESTIMATE'
    AND ncp.County = 0
    AND ncp.SumLev = 162
ORDER BY
    Population DESC,
    Name ASC;
GO

--Join to a SQL table
IF (OBJECT_ID('dbo.PopulationCenter') IS NULL)
BEGIN
    CREATE TABLE dbo.PopulationCenter
    (
        PopulationCenterName VARCHAR(30) NOT NULL PRIMARY KEY CLUSTERED
    );

    INSERT INTO dbo.PopulationCenter
    (
        PopulationCenterName
    )
    VALUES
        ('Triangle'),
        ('Triad');
END
GO
IF (OBJECT_ID('dbo.CityPopulationCenter') IS NULL)
BEGIN
    CREATE TABLE dbo.CityPopulationCenter
    (
        CityName VARCHAR(120) NOT NULL,
        PopulationCenterName VARCHAR(30) NOT NULL,
        CONSTRAINT [PK_CityPopulationCenter]
            PRIMARY KEY CLUSTERED(CityName, PopulationCenterName),
        CONSTRAINT [FK_CityPopulationCenter_PopulationCenter]
            FOREIGN KEY(PopulationCenterName)
            REFERENCES dbo.PopulationCenter(PopulationCenterName)
    );
    INSERT INTO dbo.CityPopulationCenter
    (
        CityName,
        PopulationCenterName
    )
    VALUES
        ('Burlington city', 'Triad'),
        ('Greensboro city', 'Triad'),
        ('High Point city', 'Triad'),
        ('Winston-Salem city', 'Triad'),
        ('Apex town', 'Triangle'),
        ('Cary town', 'Triangle'),
        ('Chapel Hill town', 'Triangle'),
        ('Durham city', 'Triangle'),
        ('Raleigh city', 'Triangle');
END
GO

-- This join connects an Azure Blob Storage-based table with a local SQL table.
SELECT
    ncp.Name,
    cpc.PopulationCenterName,
    ncp.Population
FROM dbo.NorthCarolinaPopulation ncp
    LEFT OUTER JOIN dbo.CityPopulationCenter cpc
        ON ncp.Name = cpc.CityName
WHERE
    ncp.Year = 2017
    AND ncp.PopulationType = 'POPESTIMATE'
    AND ncp.County = 0
    AND ncp.SumLev = 162
ORDER BY
    Population DESC,
    Name ASC;
GO

--Aggregations and other operations work too.
SELECT
    cpc.PopulationCenterName,
    SUM(ncp.Population) AS TotalPopulation
FROM dbo.NorthCarolinaPopulation ncp
    INNER JOIN dbo.CityPopulationCenter cpc
        ON ncp.Name = cpc.CityName
WHERE
    ncp.Year = 2017
    AND ncp.PopulationType = 'POPESTIMATE'
    AND ncp.County = 0
    AND ncp.SumLev = 162
GROUP BY
    cpc.PopulationCenterName;
GO
