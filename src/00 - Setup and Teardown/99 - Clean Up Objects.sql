-- Drops everything the demo flow creates inside the Scratch database,
-- in the right dependency order. Safe to re-run.
--
-- Container note: this does NOT touch the master key or the database
-- itself. Use `docker compose down -v` to wipe the entire instance.

USE [Scratch];
GO

OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

-------------------------------------------------------------------------
-- External tables and views (NC Population demo)
-------------------------------------------------------------------------
IF (OBJECT_ID('dbo.NorthCarolinaPopulationCities', 'ET') IS NOT NULL)
    DROP EXTERNAL TABLE dbo.NorthCarolinaPopulationCities;
GO
IF (OBJECT_ID('dbo.NorthCarolinaPopulation', 'ET') IS NOT NULL)
    DROP EXTERNAL TABLE dbo.NorthCarolinaPopulation;
GO
IF (OBJECT_ID('dbo.NCCountyUnemployment', 'ET') IS NOT NULL)
    DROP EXTERNAL TABLE dbo.NCCountyUnemployment;
GO
IF (OBJECT_ID('dbo.NCCountyMedianHouseholdIncome', 'ET') IS NOT NULL)
    DROP EXTERNAL TABLE dbo.NCCountyMedianHouseholdIncome;
GO

-------------------------------------------------------------------------
-- Local lookup tables (Population demo)
-------------------------------------------------------------------------
DROP TABLE IF EXISTS dbo.CityPopulationCenter;
DROP TABLE IF EXISTS dbo.PopulationCenter;
GO

-------------------------------------------------------------------------
-- Volcano demo
-------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS dbo.Volcano_GetVolcanoData;
GO
IF (OBJECT_ID('dbo.VolcanoExport', 'ET') IS NOT NULL)
    DROP EXTERNAL TABLE dbo.VolcanoExport;
GO
IF (OBJECT_ID('dbo.Eruption', 'ET') IS NOT NULL)
    DROP EXTERNAL TABLE dbo.Eruption;
GO
IF (OBJECT_ID('dbo.VolcanoType', 'ET') IS NOT NULL)
    DROP EXTERNAL TABLE dbo.VolcanoType;
GO
IF (OBJECT_ID('dbo.CountryData', 'ET') IS NOT NULL)
    DROP EXTERNAL TABLE dbo.CountryData;
GO
IF (OBJECT_ID('dbo.Volcano', 'ET') IS NOT NULL)
    DROP EXTERNAL TABLE dbo.Volcano;
GO
IF (OBJECT_ID('dbo.VolcanoTest', 'ET') IS NOT NULL)
    DROP EXTERNAL TABLE dbo.VolcanoTest;
GO

-------------------------------------------------------------------------
-- External data sources
-------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.external_data_sources WHERE name = N'RemoteSQLServer')
    DROP EXTERNAL DATA SOURCE RemoteSQLServer;
GO
IF EXISTS (SELECT 1 FROM sys.external_data_sources WHERE name = N'S3Storage')
    DROP EXTERNAL DATA SOURCE S3Storage;
GO
IF EXISTS (SELECT 1 FROM sys.external_data_sources WHERE name = N'Postgres')
    DROP EXTERNAL DATA SOURCE Postgres;
GO
IF EXISTS (SELECT 1 FROM sys.external_data_sources WHERE name = N'CosmosDB')
    DROP EXTERNAL DATA SOURCE CosmosDB;
GO
IF EXISTS (SELECT 1 FROM sys.external_data_sources WHERE name = N'AzureDataLakeStorage')
    DROP EXTERNAL DATA SOURCE AzureDataLakeStorage;
GO
IF EXISTS (SELECT 1 FROM sys.external_data_sources WHERE name = N'AzureBlobStorage')
    DROP EXTERNAL DATA SOURCE AzureBlobStorage;
GO

-------------------------------------------------------------------------
-- External file formats
-------------------------------------------------------------------------
IF EXISTS (SELECT 1 FROM sys.external_file_formats WHERE name = N'ParquetFileFormat')
    DROP EXTERNAL FILE FORMAT ParquetFileFormat;
GO
IF EXISTS (SELECT 1 FROM sys.external_file_formats WHERE name = N'ParquetFileFormatSnappy')
    DROP EXTERNAL FILE FORMAT ParquetFileFormatSnappy;
GO
IF EXISTS (SELECT 1 FROM sys.external_file_formats WHERE name = N'SemiColonFileFormat')
    DROP EXTERNAL FILE FORMAT SemiColonFileFormat;
GO
IF EXISTS (SELECT 1 FROM sys.external_file_formats WHERE name = N'CsvFileFormatWithHeader')
    DROP EXTERNAL FILE FORMAT CsvFileFormatWithHeader;
GO
IF EXISTS (SELECT 1 FROM sys.external_file_formats WHERE name = N'CsvFileFormat')
    DROP EXTERNAL FILE FORMAT CsvFileFormat;
GO

-------------------------------------------------------------------------
-- Database scoped credentials (commented out by default — container
-- users will lose them and have to docker-compose down -v to recreate).
-- Non-container users can uncomment to fully tear down.
-------------------------------------------------------------------------
/*
IF EXISTS (SELECT 1 FROM sys.database_scoped_credentials WHERE name = N'S3Credential')
    DROP DATABASE SCOPED CREDENTIAL S3Credential;
GO
IF EXISTS (SELECT 1 FROM sys.database_scoped_credentials WHERE name = N'RemoteSqlCredential')
    DROP DATABASE SCOPED CREDENTIAL RemoteSqlCredential;
GO
IF EXISTS (SELECT 1 FROM sys.database_scoped_credentials WHERE name = N'PostgresVolcanoCredential')
    DROP DATABASE SCOPED CREDENTIAL PostgresVolcanoCredential;
GO
IF EXISTS (SELECT 1 FROM sys.database_scoped_credentials WHERE name = N'CosmosCredential')
    DROP DATABASE SCOPED CREDENTIAL CosmosCredential;
GO
IF EXISTS (SELECT 1 FROM sys.database_scoped_credentials WHERE name = N'DataLakeCredential')
    DROP DATABASE SCOPED CREDENTIAL DataLakeCredential;
GO
IF EXISTS (SELECT 1 FROM sys.database_scoped_credentials WHERE name = N'AzureStorageCredential')
    DROP DATABASE SCOPED CREDENTIAL AzureStorageCredential;
GO
*/
