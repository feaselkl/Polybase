USE [Scratch]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO
DECLARE
	@year INT = 2007,
	@TableName SYSNAME,
	@sql NVARCHAR(MAX);

WHILE (@year < 2021)
BEGIN
	SET @sql = CONCAT(N'IF (OBJECT_ID(''dbo.FireIncidents', @year, ''') IS NOT NULL) DROP EXTERNAL TABLE dbo.FireIncidents', @year);
	EXEC(@sql);
	set @year = @year + 1
END
GO

-- Use Parquet for data as it compresses well and works for columnar access.
-- We'd use ORC or Parquet for fact tables with lots of rows and where the
-- typical access pattern is via aggregations.
-- Note that ORC is not supported for CETAS statements as of SQL Server 2022 RC0.
IF NOT EXISTS
(
    SELECT 1
    FROM sys.external_file_formats e
    WHERE  
        e.name = N'ParquetFileFormat'
)
BEGIN
    CREATE EXTERNAL FILE FORMAT ParquetFileFormat WITH
    (
        FORMAT_TYPE = PARQUET,
		DATA_COMPRESSION = 'org.apache.hadoop.io.compress.SnappyCodec'
    );
END
GO

-- Keep older data in external tables on blob storage.  We'll break out by year and include every year from 2017 back to 2008.
DECLARE
	@year INT = 2007,
	@TableName SYSNAME,
	@sql NVARCHAR(MAX);

WHILE (@year < 2021)
BEGIN
	SET @TableName = CONCAT(N'FireIncidents', @year);
	IF (OBJECT_ID(@TableName) IS NULL)
	BEGIN
		SET @sql = REPLACE(N'
	CREATE EXTERNAL TABLE [dbo].[FireIncidents$YEAR]
	WITH
	(
		DATA_SOURCE = AzureFireIncidentsBlob,
		LOCATION = N''FireIncidents$YEAR/'',
		FILE_FORMAT = ParquetFileFormat,
		REJECT_TYPE = VALUE,
		REJECT_VALUE = 1
	) AS
	SELECT
		[X],
		[Y],
		[OBJECTID],
		[incident_number],
		[incident_type],
		[incident_type_description],
		[arrive_date_time],
		[cleared_date_time],
		[dispatch_date_time],
		[exposure],
		[platoon],
		[station],
		[address],
		[address2],
		[apt_room],
		[GlobalID],
		[CreationDate],
		[Creator],
		[EditDate],
		[Editor]
	FROM [dbo].[FireIncidentsLocal]
		WHERE
			DispatchYear = $YEAR;', N'$YEAR', CAST(@year AS NVARCHAR(4)));
		
		EXEC(@sql);

		RAISERROR('Completed year %i', 10, 1, @year) WITH NOWAIT;
	END

	SET @year = @year + 1;
END
GO
