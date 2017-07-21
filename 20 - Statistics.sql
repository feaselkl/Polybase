USE OOTP
GO
--We can create statistics the same way as we would any other table.
CREATE STATISTICS [s_SecondBasemen_Name] ON dbo.SecondBasemen
(
	LastName,
	FirstName
) WITH FULLSCAN;

--DBCC SHOW_STATISTICS works as expected.
DBCC SHOW_STATISTICS('dbo.SecondBasemen', 's_SecondBasemen_Name')

--sys.stats and sys.stats_columns work as expected.
SELECT
	s.name,
	s.stats_id,
	s.auto_created,
	s.user_created,
	STRING_AGG(c.name, ', ') AS ColumnSet
FROM sys.stats s
	INNER JOIN sys.stats_columns sc
		ON s.object_id = sc.object_id
		AND s.stats_id = sc.stats_id
	INNER JOIN sys.columns c
		ON sc.object_id = c.object_id
		AND sc.column_id = c.column_id
WHERE
	s.name = 's_SecondBasemen_Name'
	AND s.object_id = OBJECT_ID('dbo.SecondBasemen')
GROUP BY
	s.name,
	s.stats_id,
	s.auto_created,
	s.user_created;

--sys.dm_db_stats_properties and sys.dm_db_stats_histogram do NOT work.
SELECT
	s.name,
	s.stats_id,
	ddsp.*,
	ddsh.*
FROM sys.stats s
	OUTER APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) ddsp
	OUTER APPLY sys.dm_db_stats_histogram(s.object_id, s.stats_id) ddsh
WHERE
	s.name = 's_SecondBasemen_Name'
	AND s.object_id = OBJECT_ID('dbo.SecondBasemen');

SELECT
	s.name,
	s.stats_id,
	ddsp.*,
	ddsh.*
FROM sys.stats s
	CROSS APPLY sys.dm_db_stats_properties(s.object_id, s.stats_id) ddsp
	OUTER APPLY sys.dm_db_stats_histogram(s.object_id, s.stats_id) ddsh
WHERE
	s.name = 's_SecondBasemen_Name'
	AND s.object_id = OBJECT_ID('Player.SecondBasemen');
GO
