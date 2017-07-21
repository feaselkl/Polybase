USE OOTP
GO
--This is a basic query which does not create a MapReduce job.
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
	sb.LastName DESC;
GO
