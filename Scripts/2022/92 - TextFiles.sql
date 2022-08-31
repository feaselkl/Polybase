USE [Scratch]
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO
IF NOT EXISTS
(
    SELECT 1
    FROM sys.external_data_sources ds
    WHERE
        ds.name = N'AccessTest'
)
BEGIN
    CREATE EXTERNAL DATA SOURCE AccessTest WITH
    (
        LOCATION = 'odbc://noplace',
        CONNECTION_OPTIONS = 'Driver={Microsoft Access Text Driver (*.txt, *.csv)}; DBQ=D:\SourceCode\PolyBase\Scripts\'
    );
END
GO
IF NOT EXISTS
(
    SELECT 1
    FROM sys.external_tables t
    WHERE
        t.name = N'AirportCodes'
)
BEGIN
    CREATE EXTERNAL TABLE dbo.AirportCodes
    (
        AIRPORT_ID INT,
        AIRPORT NVARCHAR(255),
        DISPLAY_AIRPORT_NAME NVARCHAR(255),
        LATITUDE FLOAT,
        LONGITUDE FLOAT
    )
    WITH
    (
        DATA_SOURCE = AccessTest,
        LOCATION = '[AirportCodeLocationLookupClean.csv]'
    );
END
GO

SELECT * FROM dbo.AirportCodes;
