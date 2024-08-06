USE Scratch
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

IF NOT EXISTS
(
	SELECT *
	FROM sys.database_scoped_credentials
	WHERE
		name = N'DataLakeCredential'
)
BEGIN
	CREATE DATABASE SCOPED CREDENTIAL DataLakeCredential
	WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
	SECRET = '<YOUR SECRET>';
END
GO
IF NOT EXISTS
(
	SELECT 1
	FROM sys.external_data_sources s
	WHERE
		s.name = N'MarsFarming'
)
BEGIN
	CREATE EXTERNAL DATA SOURCE MarsFarming WITH
	(
		LOCATION = 'abs://bdadatalake.blob.core.windows.net/synapse/marsfarming_curated',
		CREDENTIAL = DataLakeCredential
	);
END
GO
IF NOT EXISTS
(
    SELECT 1
    FROM sys.external_file_formats e
    WHERE  
        e.name = N'ParquetFileFormat'
)
BEGIN
    CREATE EXTERNAL FILE FORMAT ParquetFileFormat WITH
    (
        FORMAT_TYPE = PARQUET,
		DATA_COMPRESSION = 'org.apache.hadoop.io.compress.SnappyCodec'
    );
END
GO
IF (OBJECT_ID('dbo.ArabilityScore') IS NULL)
BEGIN
	CREATE EXTERNAL TABLE dbo.ArabilityScore
	(
		PlotID INT,
		ReportDateTime DATETIME2(0),
		ArabilityScore NUMERIC(3,2)
	)
	WITH
	(
		DATA_SOURCE = MarsFarming,
		LOCATION = N'ArabilityScore/2116/01/*.parquet',
		FILE_FORMAT = ParquetFileFormat
	);
END
GO

SELECT COUNT(*) FROM dbo.ArabilityScore;
GO
SELECT TOP(10) * from dbo.ArabilityScore;
GO
SELECT
	PlotID,
	AVG(ArabilityScore) AS AverageArabilityScore
FROM dbo.ArabilityScore
GROUP BY
	PlotID
ORDER BY
	PlotID;
GO
SELECT
	CAST(ReportDateTime AS DATE) AS ReportDate,
	AVG(ArabilityScore) AS AverageArabilityScore
FROM dbo.ArabilityScore
GROUP BY
	CAST(ReportDateTime AS DATE)
ORDER BY
	ReportDate;
GO
