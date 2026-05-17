USE [Scratch]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO
-- Turn on show execution plans to see the impact of
-- partition elimination and pushdown.

-- Just local data.
SELECT
	fil.*
FROM dbo.RaleighFireIncidents fil
WHERE
	fil.dispatch_date_time >= '2024-01-01'
	AND fil.dispatch_date_time < '2025-10-31';
GO

-- Just one blob.
SELECT
	fil.*
FROM dbo.RaleighFireIncidents fil
WHERE
	fil.dispatch_date_time >= '2014-01-01'
	AND fil.dispatch_date_time < '2014-01-31';
GO

-- Combination
SELECT
	fil.*
FROM dbo.RaleighFireIncidents fil
WHERE
	fil.dispatch_date_time >= '2020-01-01'
	AND fil.dispatch_date_time < '2026-01-31';
GO
