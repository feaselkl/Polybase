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

WHILE (@year < 2024)
BEGIN
	SET @sql = CONCAT(N'IF (OBJECT_ID(''dbo.RaleighFireIncidents', @year, ''') IS NOT NULL) DROP EXTERNAL TABLE dbo.RaleighFireIncidents', @year);
	EXEC(@sql);
	set @year = @year + 1
END
GO

-- Keep older data in external tables in Azure Blob Storage/S3.
-- We'll break out by year and include every year from 2017 back to 2008.
-- We'll also simulate this with MinIO instead of actual S3.
DECLARE
	@year INT = 2007,
	@TableName SYSNAME,
	@sql NVARCHAR(MAX);

WHILE (@year < 2024)
BEGIN
	SET @TableName = CONCAT(N'RaleighFireIncidents', @year);
	IF (OBJECT_ID(@TableName) IS NULL)
	BEGIN
		SET @sql = REPLACE(N'
        CREATE EXTERNAL TABLE [dbo].[RaleighFireIncidents$YEAR]
        WITH
        (
            DATA_SOURCE = S3Storage,
            LOCATION = N''cold-storage/RaleighFireIncidents$YEAR/'',
            FILE_FORMAT = ParquetFileFormat,
            REJECT_TYPE = VALUE,
            REJECT_VALUE = 1
        ) AS
        SELECT
            incident_number,
            incident_type,
            incident_type_description,
            arrive_date_time,
            cleared_date_time,
            dispatch_date_time,
            exposure,
            platoon,
            station,
            address,
            address2,
            apt_room
        FROM [dbo].[RaleighFireIncidents]
        WHERE
            YEAR(dispatch_date_time) = $YEAR;', N'$YEAR', CAST(@year AS NVARCHAR(4)));
		
		EXEC(@sql);

		RAISERROR('Completed year %i', 10, 1, @year) WITH NOWAIT;
	END

	SET @year = @year + 1;
END
GO