USE ForensicAccounting
GO
CREATE TABLE dbo.Bus
(
	BusID INT NOT NULL,
	DateFirstInService DATE NOT NULL,
	DateRetired DATE NULL,
	CONSTRAINT [PK_Bus] PRIMARY KEY CLUSTERED (BusID)
);

-- Start with 300 buses
INSERT INTO dbo.Bus
(
	BusID,
	DateFirstInService,
	DateRetired
)
SELECT TOP (300)
	ROW_NUMBER() OVER (ORDER BY NEWID()) AS BusID,
	'1990-01-01' AS DateFirstInService,
	NULL AS DateRetired
FROM dbo.Calendar;

-- 50 new buses each year
INSERT INTO dbo.Bus
(
	BusID,
	DateFirstInService,
	DateRetired
)
SELECT
	300 + ROW_NUMBER() OVER (ORDER BY c.Date, ao.object_id),
	c.Date,
	NULL AS DateRetired
FROM dbo.Calendar c
	CROSS JOIN ( SELECT TOP(50) object_id FROM sys.all_objects ) ao
WHERE
	c.CalendarDayOfYear = 1
	AND c.Date < '2019-01-01'
	AND c.Date >= '2014-01-01';

-- Retire ~30 buses each year
WITH candidates AS
(
	SELECT
		ROW_NUMBER() OVER (PARTITION BY c.Date ORDER BY NEWID()) AS rownum,
		c.Date,
		b.BusID,
		b.DateFirstInService,
		b.DateRetired
	FROM dbo.Calendar c
		INNER JOIN dbo.Bus b
			ON c.Date > b.DateFirstInService
	WHERE
		c.CalendarDayOfYear = 1
		AND c.Date < '2019-01-01'
		AND c.Date >= '2014-01-01'
)
UPDATE b
SET
	DateRetired = c.Date
FROM candidates c
	INNER JOIN dbo.Bus b
		ON c.BusID = b.BusID
WHERE
	c.rownum <= 36;