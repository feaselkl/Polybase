USE [Scratch]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO
-- Just local data.
SELECT
	fil.*
FROM dbo.FireIncidentsLocal fil
WHERE
	fil.dispatch_date_time >= '2021-01-01'
	AND fil.dispatch_date_time < '2022-08-31';

-- Just one blob.
SELECT
	fil.*
FROM dbo.FireIncidentsLocal fil
WHERE
	fil.dispatch_date_time >= '2014-01-01'
	AND fil.dispatch_date_time < '2014-01-31';

-- Combination
SELECT
	fil.*
FROM dbo.FireIncidentsLocal fil
WHERE
	fil.dispatch_date_time >= '2020-01-01'
	AND fil.dispatch_date_time < '2021-01-31';