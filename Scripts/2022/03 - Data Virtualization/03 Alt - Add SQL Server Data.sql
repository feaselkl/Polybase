USE [Scratch]
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO
IF NOT EXISTS
(
    SELECT 1
    FROM sys.external_tables t
    WHERE
        t.name = N'VolcanoType'
)
BEGIN
    CREATE EXTERNAL TABLE dbo.VolcanoType
    (
        Type NVARCHAR(100),
        Description NVARCHAR(650)
    )
    WITH
    (
        DATA_SOURCE = Desktop,
		LOCATION = 'ForensicAccounting.dbo.VolcanoType'
    );
END
GO

SELECT
		_id,
		v.VolcanoName,
		v.Country,
		c.Area,
		c.GDP,
		c.GDPPerCapita,
		c.RealGrowthRate,
		c.Population,
		c.LaborForce,
		c.LifeExpectancy,
		v.Region,
		v.Location_Type AS LocationType,
		v.Elevation,
		v.Type,
        vt.Description,
		v.Status,
		v.LastEruption
	FROM dbo.Volcano2 v
		LEFT OUTER JOIN dbo.CountryData c
			ON v.Country = c.Country
        LEFT OUTER JOIN dbo.VolcanoType vt
            ON v.Type = vt.Type
	ORDER BY
		v.Elevation ASC;