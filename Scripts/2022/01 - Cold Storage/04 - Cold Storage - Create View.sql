USE [Scratch]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS
(
	SELECT 1
	FROM sys.views v
	WHERE
		v.name = N'FireIncidentsLocal'
)
BEGIN
	BEGIN TRANSACTION
	EXEC sp_rename N'dbo.FireIncidentsLocal', N'FireIncidentsOld';
	-- Views must be the first operation in a batch, so we need to do this as dynamic SQL.
	-- This view happens to match columns but that's not required; we could have schema changes over time.
	--	The view would simply need to show one consistent output.
	EXEC(N'
	CREATE VIEW dbo.FireIncidentsLocal AS
		SELECT * FROM dbo.FireIncidents2007 WHERE dispatch_date_time >= ''2007-01-01'' AND dispatch_date_time < ''2008-01-01''
		UNION ALL
		SELECT * FROM dbo.FireIncidents2008 WHERE dispatch_date_time >= ''2008-01-01'' AND dispatch_date_time < ''2009-01-01''
		UNION ALL
		SELECT * FROM dbo.FireIncidents2009 WHERE dispatch_date_time >= ''2009-01-01'' AND dispatch_date_time < ''2010-01-01''
		UNION ALL
		SELECT * FROM dbo.FireIncidents2010 WHERE dispatch_date_time >= ''2010-01-01'' AND dispatch_date_time < ''2011-01-01''
		UNION ALL
		SELECT * FROM dbo.FireIncidents2011 WHERE dispatch_date_time >= ''2011-01-01'' AND dispatch_date_time < ''2012-01-01''
		UNION ALL
		SELECT * FROM dbo.FireIncidents2012 WHERE dispatch_date_time >= ''2012-01-01'' AND dispatch_date_time < ''2013-01-01''
		UNION ALL
		SELECT * FROM dbo.FireIncidents2013 WHERE dispatch_date_time >= ''2013-01-01'' AND dispatch_date_time < ''2014-01-01''
		UNION ALL
		SELECT * FROM dbo.FireIncidents2014 WHERE dispatch_date_time >= ''2014-01-01'' AND dispatch_date_time < ''2015-01-01''
		UNION ALL
		SELECT * FROM dbo.FireIncidents2015 WHERE dispatch_date_time >= ''2015-01-01'' AND dispatch_date_time < ''2016-01-01''
		UNION ALL
		SELECT * FROM dbo.FireIncidents2016 WHERE dispatch_date_time >= ''2016-01-01'' AND dispatch_date_time < ''2017-01-01''
		UNION ALL
		SELECT * FROM dbo.FireIncidents2017 WHERE dispatch_date_time >= ''2017-01-01'' AND dispatch_date_time < ''2018-01-01''
		UNION ALL
		SELECT * FROM dbo.FireIncidents2018 WHERE dispatch_date_time >= ''2018-01-01'' AND dispatch_date_time < ''2019-01-01''
		UNION ALL
		SELECT * FROM dbo.FireIncidents2019 WHERE dispatch_date_time >= ''2019-01-01'' AND dispatch_date_time < ''2020-01-01''
		UNION ALL
		SELECT * FROM dbo.FireIncidents2020 WHERE dispatch_date_time >= ''2020-01-01'' AND dispatch_date_time < ''2021-01-01''
		UNION ALL
		SELECT * FROM dbo.FireIncidents2021 WHERE dispatch_date_time >= ''2021-01-01'' AND dispatch_date_time < ''2022-01-01''
		UNION ALL
		SELECT * FROM dbo.FireIncidents2022 WHERE dispatch_date_time >= ''2022-01-01'' AND dispatch_date_time < ''2023-01-01''
		UNION ALL
		SELECT * FROM dbo.FireIncidentsNull WHERE dispatch_date_time IS NULL');
	COMMIT
END
GO
