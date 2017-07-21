USE OOTP
GO
--We can use the same T-SQL syntax that we'd use for any other query.
--Note that Blob Storage pulls the *entire* file down each time!
--That's a big part of why we're only using a small sample here.

SELECT
	f.*
FROM dbo.Flights2008Sample f;

SELECT
	fa.[year],
	COUNT(1) AS NumberOfRecords
FROM dbo.Flights2008Sample fa
GROUP BY
	fa.[year]
ORDER BY
	fa.[year];