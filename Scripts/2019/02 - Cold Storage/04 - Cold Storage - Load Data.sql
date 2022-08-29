USE [Scratch]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO
--To insert data, first we need to make sure that
--PolyBase insertion is turned on.
EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE
GO
EXEC sp_configure 'allow polybase export', 1;
GO
RECONFIGURE
GO

-- Load each year's worth of data into its own partitioned table.
DECLARE
	@year INT = 2008,
	@TableName SYSNAME,
	@sql NVARCHAR(MAX);

WHILE (@year < 2020)
BEGIN
	SET @TableName = CONCAT(N'FireIncidents', @year);
	SET @sql = REPLACE(N'
	IF NOT EXISTS(SELECT 1 FROM dbo.FireIncidents$YEAR)
	BEGIN
		INSERT INTO dbo.FireIncidents$YEAR
		(
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
		)
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
				YEAR(dispatch_date_time) = $YEAR;
	END', N'$YEAR', CAST(@year AS NVARCHAR(4)));

	EXEC(@sql);
	SET @year = @year + 1;
END
GO

-- Don't forget about the rows where the dispatch date is NULL.
IF NOT EXISTS(SELECT 1 FROM dbo.FireIncidentsNull)
BEGIN
	INSERT INTO dbo.FireIncidentsNull
	(
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
	)
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
			dispatch_date_time IS NULL;
END
GO

-- Now create statistics on all of the external tables.  This will let the optimizer know
-- that we have partitioned each table by year.
DECLARE
	@year INT = 2008,
	@TableName SYSNAME,
	@sql NVARCHAR(MAX);

WHILE (@year < 2018)
BEGIN
	SET @TableName = CONCAT(N'FireIncidents', @year);
	SET @sql = REPLACE(N'
	IF NOT EXISTS (SELECT 1 FROM sys.stats WHERE name = N''sFireIncidents$YEAR_DispatchDateTime'')
	BEGIN
		CREATE STATISTICS [sFireIncidents$YEAR_DispatchDateTime]
		ON dbo.FireIncidents$YEAR(dispatch_date_time)
		WITH FULLSCAN;
	END', N'$YEAR', CAST(@year AS NVARCHAR(4)));
		
		EXEC(@sql);

	SET @year = @year + 1;
END
GO

