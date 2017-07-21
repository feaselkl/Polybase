USE OOTP
GO
--Azure Blob Storage requires that we create a master key.
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '{password}';
GO
--Our database-scoped credential will allow us to communicate
--with Azure.  Use one of the two access keys in your Azure portal.
--It doesn't matter if you use the primary or secondary key here.
CREATE DATABASE SCOPED CREDENTIAL AzureStorageCredential
WITH IDENTITY = 'cspolybase',
SECRET = '{access key}';
GO
--Because we have a secured blob, we need to authenticate using the credential
--that we just created.
CREATE EXTERNAL DATA SOURCE WASBFlights
WITH (
	TYPE = HADOOP,
	LOCATION = 'wasbs://csflights@cspolybase.blob.core.windows.net',
	CREDENTIAL = AzureStorageCredential
);

--If you've been following along so far, you probably already have
--this file format.  Otherwise, create it with the script below.
CREATE EXTERNAL FILE FORMAT [CsvFileFormat] WITH
(
	FORMAT_TYPE = DELIMITEDTEXT,
	FORMAT_OPTIONS
	(
		FIELD_TERMINATOR = N',',
		USE_TYPE_DEFAULT = TRUE
	)
);

--We can create an external table for each of the years of flights.
--This is for 2008, but other years are available as well.
--Note that this is a stripped-down version of the 2008 flights data set.
CREATE EXTERNAL TABLE [dbo].[Flights2008Sample]
(
	[year] [INT] NULL,
	[month] [INT] NULL,
	[dayofmonth] [INT] NULL,
	[dayofweek] [INT] NULL,
	[deptime] [VARCHAR](100) NULL,
	[crsdeptime] [VARCHAR](100) NULL,
	[arrtime] [VARCHAR](100) NULL,
	[crsarrtime] [VARCHAR](100) NULL,
	[uniquecarrier] [VARCHAR](100) NULL,
	[flightnum] [VARCHAR](100) NULL,
	[tailnum] [VARCHAR](100) NULL,
	[actualelapsedtime] [VARCHAR](100) NULL,
	[crselapsedtime] [VARCHAR](100) NULL,
	[airtime] [VARCHAR](100) NULL,
	[arrdelay] [VARCHAR](100) NULL,
	[depdelay] [VARCHAR](100) NULL,
	[origin] [VARCHAR](100) NULL,
	[dest] [VARCHAR](100) NULL,
	[distance] [VARCHAR](100) NULL,
	[taxiin] [VARCHAR](100) NULL,
	[taxiout] [VARCHAR](100) NULL,
	[cancelled] [VARCHAR](100) NULL,
	[cancellationcode] [VARCHAR](100) NULL,
	[diverted] [VARCHAR](100) NULL,
	[carrierdelay] [VARCHAR](100) NULL,
	[weatherdelay] [VARCHAR](100) NULL,
	[nasdelay] [VARCHAR](100) NULL,
	[securitydelay] [VARCHAR](100) NULL,
	[lateaircraftdelay] [VARCHAR](100) NULL
)
WITH
(
	DATA_SOURCE = [WASBFlights],
	LOCATION = N'sample/2008.csv.bz2',
	FILE_FORMAT = [CsvFileFormat],
	REJECT_TYPE = VALUE,
	REJECT_VALUE = 5000
);
GO

SELECT TOP (10)
	*
FROM dbo.Flights2008Sample fs;
GO
