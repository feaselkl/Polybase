USE OOTP
GO
--This is a query which performs some aggregations.
--For a larger data set, this would probably result
--in a MapReduce job, but because the SecondBasemen
--data set is so small, we're going to force job creation.
SELECT
	sb.LastName,
	MIN(sb.Age) AS MinAge,
	MAX(sb.Age) AS MaxAge,
	COUNT(1) AS NumberOfSecondBasemen
FROM dbo.SecondBasemen sb
GROUP BY
	sb.LastName
HAVING
	COUNT(1) > 2
OPTION(FORCE EXTERNALPUSHDOWN);
