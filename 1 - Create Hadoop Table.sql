--Before running this, follow the instructions at:
-- https://www.mssqltips.com/sqlservertip/4080/introduction-to-polybase-in-sql-server-2016--part-1/
-- This will configure your SQL Server box for Polybase.
USE [OOTP]
GO
CREATE EXTERNAL DATA SOURCE [HDP] WITH
(
	TYPE = Hadoop,
	LOCATION = N'hdfs://sandbox.hortonworks.com:8020',
	RESOURCE_MANAGER_LOCATION=N'sandbox.hortonworks.com:8050'
)
GO
--We're only reading CSVs in this case, so we only need this one file format.
CREATE EXTERNAL FILE FORMAT [CsvFileFormat]
WITH (FORMAT_TYPE = DelimitedText, FORMAT_OPTIONS (FIELD_TERMINATOR = N',', USE_TYPE_DEFAULT = True))
GO
CREATE EXTERNAL TABLE [dbo].[SecondBasemen]
(
	[FirstName] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[Age] [int] NULL,
	[Throws] [varchar](5) NULL,
	[Bats] [varchar](5) NULL
)
WITH
(
	LOCATION = N'/tmp/ootp/SecondBasemen.csv',
	DATA_SOURCE = HDP,
	FILE_FORMAT = CsvFileFormat,
	-- Up to 5 rows can have bad values before Polybase returns an error.
	REJECT_TYPE = Value,
	REJECT_VALUE = 5
)
GO
--Very basic test of the table.
SELECT
	sb.FirstName,
	sb.LastName,
	sb.Age,
	sb.Throws,
	sb.Bats
FROM dbo.SecondBasemen sb;
GO
