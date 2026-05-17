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
		v.name = N'RaleighFireIncidents'
)
BEGIN
	BEGIN TRANSACTION
	EXEC sp_rename N'dbo.RaleighFireIncidents', N'RaleighFireIncidentsOld';
	-- Views must be the first operation in a batch, so we need to do
	-- this as dynamic SQL.
	EXEC(N'
	CREATE VIEW dbo.RaleighFireIncidents AS
		SELECT * FROM dbo.RaleighFireIncidents2007 WHERE dispatch_date_time >= ''2007-01-01'' AND dispatch_date_time < ''2008-01-01''
		UNION ALL
		SELECT * FROM dbo.RaleighFireIncidents2008 WHERE dispatch_date_time >= ''2008-01-01'' AND dispatch_date_time < ''2009-01-01''
		UNION ALL
		SELECT * FROM dbo.RaleighFireIncidents2009 WHERE dispatch_date_time >= ''2009-01-01'' AND dispatch_date_time < ''2010-01-01''
		UNION ALL
		SELECT * FROM dbo.RaleighFireIncidents2010 WHERE dispatch_date_time >= ''2010-01-01'' AND dispatch_date_time < ''2011-01-01''
		UNION ALL
		SELECT * FROM dbo.RaleighFireIncidents2011 WHERE dispatch_date_time >= ''2011-01-01'' AND dispatch_date_time < ''2012-01-01''
		UNION ALL
		SELECT * FROM dbo.RaleighFireIncidents2012 WHERE dispatch_date_time >= ''2012-01-01'' AND dispatch_date_time < ''2013-01-01''
		UNION ALL
		SELECT * FROM dbo.RaleighFireIncidents2013 WHERE dispatch_date_time >= ''2013-01-01'' AND dispatch_date_time < ''2014-01-01''
		UNION ALL
		SELECT * FROM dbo.RaleighFireIncidents2014 WHERE dispatch_date_time >= ''2014-01-01'' AND dispatch_date_time < ''2015-01-01''
		UNION ALL
		SELECT * FROM dbo.RaleighFireIncidents2015 WHERE dispatch_date_time >= ''2015-01-01'' AND dispatch_date_time < ''2016-01-01''
		UNION ALL
		SELECT * FROM dbo.RaleighFireIncidents2016 WHERE dispatch_date_time >= ''2016-01-01'' AND dispatch_date_time < ''2017-01-01''
		UNION ALL
		SELECT * FROM dbo.RaleighFireIncidents2017 WHERE dispatch_date_time >= ''2017-01-01'' AND dispatch_date_time < ''2018-01-01''
		UNION ALL
		SELECT * FROM dbo.RaleighFireIncidents2018 WHERE dispatch_date_time >= ''2018-01-01'' AND dispatch_date_time < ''2019-01-01''
		UNION ALL
		SELECT * FROM dbo.RaleighFireIncidents2019 WHERE dispatch_date_time >= ''2019-01-01'' AND dispatch_date_time < ''2020-01-01''
		UNION ALL
		SELECT * FROM dbo.RaleighFireIncidents2020 WHERE dispatch_date_time >= ''2020-01-01'' AND dispatch_date_time < ''2021-01-01''
		UNION ALL
		SELECT * FROM dbo.RaleighFireIncidents2021 WHERE dispatch_date_time >= ''2021-01-01'' AND dispatch_date_time < ''2022-01-01''
		UNION ALL
		SELECT * FROM dbo.RaleighFireIncidents2022 WHERE dispatch_date_time >= ''2022-01-01'' AND dispatch_date_time < ''2023-01-01''
		UNION ALL
        SELECT * FROM dbo.RaleighFireIncidents2023 WHERE dispatch_date_time >= ''2023-01-01'' AND dispatch_date_time < ''2024-01-01''
		UNION ALL
        SELECT * FROM dbo.RaleighFireIncidents2024 WHERE dispatch_date_time >= ''2024-01-01'' AND dispatch_date_time < ''2025-01-01''
		UNION ALL
        SELECT * FROM dbo.RaleighFireIncidents2025 WHERE dispatch_date_time >= ''2025-01-01'' AND dispatch_date_time < ''2026-01-01''
		UNION ALL
		SELECT * FROM dbo.RaleighFireIncidentsNull WHERE dispatch_date_time IS NULL');
	COMMIT
END
GO