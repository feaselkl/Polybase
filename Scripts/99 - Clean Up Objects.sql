USE [Scratch]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO
-- Basic Setup
IF EXISTS
(
	SELECT 1
	FROM sys.tables
	WHERE
		name = N'NorthCarolinaPopulation'
)
BEGIN
	DROP EXTERNAL TABLE dbo.NorthCarolinaPopulation;
END
GO
IF EXISTS
(
	SELECT 1
	FROM sys.tables
	WHERE
		name = N'RemoteEmployee'
)
BEGIN
	DROP EXTERNAL TABLE dbo.RemoteEmployee;
END
GO
IF EXISTS
(
	SELECT 1
	FROM sys.tables
	WHERE
		name = N'Volcano'
)
BEGIN
	DROP EXTERNAL TABLE dbo.Volcano;
END
GO
IF EXISTS
(
	SELECT 1
	FROM sys.tables
	WHERE
		name = N'Volcano2'
)
BEGIN
	DROP EXTERNAL TABLE dbo.Volcano2;
END
GO

-- Cold Storage
DECLARE
	@year INT = 2008,
	@TableName SYSNAME,
	@sql NVARCHAR(MAX);

WHILE (@year < 2018)
BEGIN
	SET @sql = CONCAT(N'IF (OBJECT_ID(''dbo.FireIncidents', @year, ''') IS NOT NULL) DROP EXTERNAL TABLE dbo.FireIncidents', @year);
	EXEC(@sql);
	set @year = @year + 1
END
GO
DROP TABLE IF EXISTS dbo.FireIncidents2018;
DROP TABLE IF EXISTS dbo.FireIncidents2019;
DROP TABLE IF EXISTS dbo.FireIncidentsNull;
DROP TABLE IF EXISTS dbo.FireIncidentsOld;
DROP VIEW IF EXISTS dbo.FireIncidentsLocal;

-- ELT
IF (OBJECT_ID('ELT.Employee') IS NOT NULL)
BEGIN
	DROP EXTERNAL TABLE ELT.Employee;
END

IF (OBJECT_ID('ELT.Bus') IS NOT NULL)
BEGIN
	DROP EXTERNAL TABLE ELT.Bus;
END

IF (OBJECT_ID('ELT.Calendar') IS NOT NULL)
BEGIN
	DROP EXTERNAL TABLE ELT.Calendar;
END

IF (OBJECT_ID('ELT.ExpenseCategory') IS NOT NULL)
BEGIN
	DROP EXTERNAL TABLE ELT.ExpenseCategory;
END

IF (OBJECT_ID('ELT.Vendor') IS NOT NULL)
BEGIN
	DROP EXTERNAL TABLE ELT.Vendor;
END

IF (OBJECT_ID('ELT.VendorExpenseCategory') IS NOT NULL)
BEGIN
	DROP EXTERNAL TABLE ELT.VendorExpenseCategory;
END

IF (OBJECT_ID('ELT.LineItem') IS NOT NULL)
BEGIN
	DROP EXTERNAL TABLE ELT.LineItem;
END
GO

-- Data Virtualization
DROP PROCEDURE IF EXISTS dbo.Volcano_GetVolcanoData;
GO
IF (OBJECT_ID('dbo.Volcano') IS NOT NULL)
BEGIN
	DROP EXTERNAL TABLE dbo.Volcano;
END
GO
IF (OBJECT_ID('dbo.CountryData') IS NOT NULL)
BEGIN
	DROP EXTERNAL TABLE dbo.CountryData;
END

-- External objects
IF EXISTS
(
	SELECT 1
	FROM sys.external_file_formats f
	WHERE
		name = N'CsvFileFormat'
)
BEGIN
	DROP EXTERNAL FILE FORMAT CsvFileFormat;
END
GO
IF EXISTS
(
	SELECT 1
	FROM sys.external_file_formats f
	WHERE
		name = N'OrcFileFormat'
)
BEGIN
	DROP EXTERNAL FILE FORMAT OrcFileFormat;
END
GO
IF EXISTS
(
	SELECT 1
	FROM sys.external_file_formats f
	WHERE
		name = N'SemiColonFileFormat'
)
BEGIN
	DROP EXTERNAL FILE FORMAT SemiColonFileFormat;
END
GO
/*IF EXISTS
(
	SELECT 1
	FROM sys.external_data_sources d
	WHERE
		d.name = N'AzureFireIncidentsBlob'
)
BEGIN
	DROP EXTERNAL DATA SOURCE AzureFireIncidentsBlob;
END
GO
IF EXISTS
(
	SELECT 1
	FROM sys.external_data_sources d
	WHERE
		d.name = N'AzureNCPopBlob'
)
BEGIN
	DROP EXTERNAL DATA SOURCE AzureNCPopBlob;
END
GO
IF EXISTS
(
	SELECT 1
	FROM sys.external_data_sources d
	WHERE
		d.name = N'CosmosDB'
)
BEGIN
	DROP EXTERNAL DATA SOURCE CosmosDB;
END
GO*/
IF EXISTS
(
	SELECT 1
	FROM sys.external_data_sources d
	WHERE
		d.name = N'Desktop'
)
BEGIN
	DROP EXTERNAL DATA SOURCE Desktop;
END
GO
