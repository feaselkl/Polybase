USE OOTP
GO
--This is the same query as before, except that
--we are forcing external pushdown.  This will force
--the creation of a MapReduce job when otherwise we'd
--likely stream the data over until we got to a very large
--nubmer of rows.
SELECT TOP (50)
	sb.FirstName,
	sb.LastName,
	sb.Age,
	a.AgeDesc,
	sb.Throws,
	sb.Bats,
	tsa.TopSalary
FROM dbo.SecondBasemen sb
	CROSS APPLY (SELECT CASE WHEN Age > 30 THEN 'Old' ELSE 'Not Old' END AS AgeDesc) a
	INNER JOIN dbo.TopSalaryByAge tsa
		ON sb.Age = tsa.Age
ORDER BY
	sb.LastName DESC
OPTION(FORCE EXTERNALPUSHDOWN);
GO
