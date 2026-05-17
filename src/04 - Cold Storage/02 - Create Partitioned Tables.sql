USE [Scratch]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Keep the latest data in SQL Server for fast retrieval
IF (OBJECT_ID('dbo.RaleighFireIncidents2025') IS NULL)
BEGIN
	CREATE TABLE dbo.RaleighFireIncidents2025
	(
		incident_number            NVARCHAR(20)  NULL,
        incident_type              INT           NULL,
        incident_type_description  NVARCHAR(100) NULL,
        arrive_date_time           DATETIME2(0)  NULL,
        cleared_date_time          DATETIME2(0)  NULL,
        dispatch_date_time         DATETIME2(0)  NULL,
        exposure                   INT           NULL,
        platoon                    NVARCHAR(5)   NULL,
        station                    INT           NULL,
        address                    NVARCHAR(150) NULL,
        address2                   NVARCHAR(150) NULL,
        apt_room                   NVARCHAR(50)  NULL
	) ON [PRIMARY]

	ALTER TABLE dbo.RaleighFireIncidents2025 ADD CONSTRAINT [CK_FireIncidents2025_DispatchDateTime] CHECK
	(
		dispatch_date_time >= '2025-01-01' AND dispatch_date_time < '2026-01-01'
	);
END
GO
IF (OBJECT_ID('dbo.RaleighFireIncidents2024') IS NULL)
BEGIN
	CREATE TABLE dbo.RaleighFireIncidents2024
	(
		incident_number            NVARCHAR(20)  NULL,
        incident_type              INT           NULL,
        incident_type_description  NVARCHAR(100) NULL,
        arrive_date_time           DATETIME2(0)  NULL,
        cleared_date_time          DATETIME2(0)  NULL,
        dispatch_date_time         DATETIME2(0)  NULL,
        exposure                   INT           NULL,
        platoon                    NVARCHAR(5)   NULL,
        station                    INT           NULL,
        address                    NVARCHAR(150) NULL,
        address2                   NVARCHAR(150) NULL,
        apt_room                   NVARCHAR(50)  NULL
	) ON [PRIMARY]

	ALTER TABLE dbo.RaleighFireIncidents2024 ADD CONSTRAINT [CK_FireIncidents2024_DispatchDateTime] CHECK
	(
		dispatch_date_time >= '2024-01-01' AND dispatch_date_time < '2025-01-01'
	);
END
GO
-- This is a compromise solution to deal with missing initial data.
-- We could keep it in SQL Server or archive it if we know new rows
-- won't have NULL dispatch dates.
IF (OBJECT_ID('dbo.RaleighFireIncidentsNull') IS NULL)
BEGIN
	CREATE TABLE dbo.RaleighFireIncidentsNull
	(
		incident_number            NVARCHAR(20)  NULL,
        incident_type              INT           NULL,
        incident_type_description  NVARCHAR(100) NULL,
        arrive_date_time           DATETIME2(0)  NULL,
        cleared_date_time          DATETIME2(0)  NULL,
        dispatch_date_time         DATETIME2(0)  NULL,
        exposure                   INT           NULL,
        platoon                    NVARCHAR(5)   NULL,
        station                    INT           NULL,
        address                    NVARCHAR(150) NULL,
        address2                   NVARCHAR(150) NULL,
        apt_room                   NVARCHAR(50)  NULL
	) ON [PRIMARY]

	ALTER TABLE dbo.RaleighFireIncidentsNull ADD CONSTRAINT [CK_FireIncidentsNull_DispatchDateTime] CHECK
	(
		dispatch_date_time IS NULL
	);
END
GO
-- Load each year's worth of data into its own partitioned table.
DECLARE
	@year INT = 2024,
	@TableName SYSNAME,
	@sql NVARCHAR(MAX);

WHILE (@year < 2026)
BEGIN
	SET @TableName = CONCAT(N'RaleighFireIncidents', @year);
	SET @sql = REPLACE(N'
	IF NOT EXISTS(SELECT 1 FROM dbo.RaleighFireIncidents$YEAR)
	BEGIN
		INSERT INTO dbo.RaleighFireIncidents$YEAR
		(
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
		)
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
				YEAR(dispatch_date_time) = $YEAR;
	END', N'$YEAR', CAST(@year AS NVARCHAR(4)));

	EXEC(@sql);
	SET @year = @year + 1;
END
GO

-- Don't forget about the rows where the dispatch date is NULL.
IF NOT EXISTS(SELECT 1 FROM dbo.RaleighFireIncidentsNull)
BEGIN
	INSERT INTO dbo.RaleighFireIncidentsNull
	(
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
	)
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
			dispatch_date_time IS NULL;
END
GO