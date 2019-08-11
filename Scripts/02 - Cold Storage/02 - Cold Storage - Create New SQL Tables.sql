USE [Scratch]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Keep the latest data in SQL Server for fast retrieval
IF (OBJECT_ID('dbo.FireIncidents2019') IS NULL)
BEGIN
	CREATE TABLE [dbo].[FireIncidents2019]
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

	ALTER TABLE dbo.FireIncidents2019 ADD CONSTRAINT [CK_FireIncidents2019_DispatchDateTime] CHECK
	(
		dispatch_date_time >= '2019-01-01' AND dispatch_date_time < '2020-01-01'
	);
END
GO
IF (OBJECT_ID('dbo.FireIncidents2018') IS NULL)
BEGIN
	CREATE TABLE [dbo].[FireIncidents2018]
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

	ALTER TABLE dbo.FireIncidents2018 ADD CONSTRAINT [CK_FireIncidents2018_DispatchDateTime] CHECK
	(
		dispatch_date_time >= '2018-01-01' AND dispatch_date_time < '2019-01-01'
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
