USE [Scratch]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Load the data from the fire incidents text data set into FireIncidentsBackup.
IF (OBJECT_ID('dbo.FireIncidentsBackup') IS NULL)
BEGIN
	CREATE TABLE [dbo].[FireIncidentsBackup]
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
END
GO
-- Now move this data into a local table.
-- In practice we don't need to perform this step, but I want a repeatable demo.
DROP TABLE IF EXISTS dbo.FireIncidentsLocal;
GO
IF (OBJECT_ID('dbo.FireIncidentsLocal') IS NULL)
BEGIN
	CREATE TABLE [dbo].[FireIncidentsLocal]
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
	) ON [PRIMARY];

	INSERT INTO dbo.FireIncidentsLocal
	SELECT * FROM dbo.FireIncidentsBackup;
END
GO
