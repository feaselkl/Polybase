USE OOTP
GO
--When writing to Azure Blob Storage, we follow the same process as Hadoop.
CREATE EXTERNAL TABLE [dbo].[SecondBasemenWASB]
(
	[FirstName] [VARCHAR](50) NULL,
	[LastName] [VARCHAR](50) NULL,
	[Age] [INT] NULL,
	[Throws] [VARCHAR](5) NULL,
	[Bats] [VARCHAR](5) NULL
)
WITH
(
	DATA_SOURCE = [WASBFlights],
	LOCATION = N'ootp/',
	FILE_FORMAT = [CsvFileFormat],
	REJECT_TYPE = VALUE,
	REJECT_VALUE = 5
);
GO

--Player.SecondBasemen is a local copy of the table.
INSERT INTO dbo.SecondBasemenWASB
(
	FirstName,
	LastName,
	Age,
	Throws,
	Bats
)
SELECT
	sb.FirstName,
	sb.LastName,
	sb.Age,
	sb.Throws,
	sb.Bats
FROM Player.SecondBasemen sb;
GO
