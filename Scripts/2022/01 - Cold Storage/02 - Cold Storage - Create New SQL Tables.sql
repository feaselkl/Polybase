USE [Scratch]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Keep the latest data in SQL Server for fast retrieval
IF (OBJECT_ID('dbo.FireIncidents2022') IS NULL)
BEGIN
	CREATE TABLE [dbo].[FireIncidents2022]
	(
		[X] [float] NULL,
		[Y] [float] NULL,
		[OBJECTID] [int] NULL,
		[incident_number] [nvarchar](500) NULL,
		[incident_type] [smallint] NULL,
		[incident_type_description] [nvarchar](500) NULL,
		[arrive_date_time] [datetime2](7) NULL,
		[cleared_date_time] [datetime2](7) NULL,
		[dispatch_date_time] [datetime2](7) NULL,
		[exposure] [tinyint] NULL,
		[platoon] [nvarchar](50) NULL,
		[station] [tinyint] NULL,
		[address] [nvarchar](500) NULL,
		[address2] [nvarchar](500) NULL,
		[apt_room] [nvarchar](500) NULL,
		[GlobalID] [nvarchar](50) NULL,
		[CreationDate] [datetime2](7) NULL,
		[Creator] [nvarchar](50) NULL,
		[EditDate] [datetime2](7) NULL,
		[Editor] [nvarchar](50) NULL
	) ON [PRIMARY]

	ALTER TABLE dbo.FireIncidents2022 ADD CONSTRAINT [CK_FireIncidents2022_DispatchDateTime] CHECK
	(
		dispatch_date_time >= '2022-01-01' AND dispatch_date_time < '2023-01-01'
	);
END
GO
IF (OBJECT_ID('dbo.FireIncidents2021') IS NULL)
BEGIN
	CREATE TABLE [dbo].[FireIncidents2021]
	(
		[X] [float] NULL,
		[Y] [float] NULL,
		[OBJECTID] [int] NULL,
		[incident_number] [nvarchar](500) NULL,
		[incident_type] [smallint] NULL,
		[incident_type_description] [nvarchar](500) NULL,
		[arrive_date_time] [datetime2](7) NULL,
		[cleared_date_time] [datetime2](7) NULL,
		[dispatch_date_time] [datetime2](7) NULL,
		[exposure] [tinyint] NULL,
		[platoon] [nvarchar](50) NULL,
		[station] [tinyint] NULL,
		[address] [nvarchar](500) NULL,
		[address2] [nvarchar](500) NULL,
		[apt_room] [nvarchar](500) NULL,
		[GlobalID] [nvarchar](50) NULL,
		[CreationDate] [datetime2](7) NULL,
		[Creator] [nvarchar](50) NULL,
		[EditDate] [datetime2](7) NULL,
		[Editor] [nvarchar](50) NULL
	) ON [PRIMARY]

	ALTER TABLE dbo.FireIncidents2021 ADD CONSTRAINT [CK_FireIncidents2021_DispatchDateTime] CHECK
	(
		dispatch_date_time >= '2021-01-01' AND dispatch_date_time < '2022-01-01'
	);
END
GO
-- This is a compromise solution to deal with missing initial data.  We could keep it in SQL Server
-- or archive it if we know new rows won't have NULL dispatch dates.
IF (OBJECT_ID('dbo.FireIncidentsNull') IS NULL)
BEGIN
	CREATE TABLE [dbo].[FireIncidentsNull]
	(
		[X] [float] NULL,
		[Y] [float] NULL,
		[OBJECTID] [int] NULL,
		[incident_number] [nvarchar](500) NULL,
		[incident_type] [smallint] NULL,
		[incident_type_description] [nvarchar](500) NULL,
		[arrive_date_time] [datetime2](7) NULL,
		[cleared_date_time] [datetime2](7) NULL,
		[dispatch_date_time] [datetime2](7) NULL,
		[exposure] [tinyint] NULL,
		[platoon] [nvarchar](50) NULL,
		[station] [tinyint] NULL,
		[address] [nvarchar](500) NULL,
		[address2] [nvarchar](500) NULL,
		[apt_room] [nvarchar](500) NULL,
		[GlobalID] [nvarchar](50) NULL,
		[CreationDate] [datetime2](7) NULL,
		[Creator] [nvarchar](50) NULL,
		[EditDate] [datetime2](7) NULL,
		[Editor] [nvarchar](50) NULL
	) ON [PRIMARY]

	ALTER TABLE dbo.FireIncidentsNull ADD CONSTRAINT [CK_FireIncidentsNull_DispatchDateTime] CHECK
	(
		dispatch_date_time IS NULL
	);
END
GO
-- Load each year's worth of data into its own partitioned table.
DECLARE
	@year INT = 2021,
	@TableName SYSNAME,
	@sql NVARCHAR(MAX);

WHILE (@year < 2023)
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
				DispatchYear = $YEAR;
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
			DispatchYear IS NULL;
END
GO