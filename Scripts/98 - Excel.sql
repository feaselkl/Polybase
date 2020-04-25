USE [Scratch]
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.external_data_sources ds
    WHERE
        ds.name = N'NorthCarolinaPopulationExcelUntyped'
)
BEGIN
    CREATE EXTERNAL DATA SOURCE NorthCarolinaPopulationExcelUntyped WITH
    (
        LOCATION = 'odbc://noplace',
        CONNECTION_OPTIONS = 'Driver={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)}; DBQ=C:\SourceCode\Polybase\NorthCarolinaPopulation.xlsx'
    );
END
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.external_tables t
    WHERE
        t.name = N'NorthCarolinaPopulationExcelUntyped'
)
BEGIN
    CREATE EXTERNAL TABLE dbo.NorthCarolinaPopulationExcelUntyped
    (
        SUMLEV FLOAT(53),
        COUNTY FLOAT(53),
        PLACE FLOAT(53),
        PRIMGEO_FLAG FLOAT(53),
        NAME NVARCHAR(255),
        POPTYPE NVARCHAR(255),
        YEAR FLOAT(53),
        POPULATION FLOAT(53)
    )
    WITH
    (
        LOCATION = 'NorthCarolinaPopulation$',
        DATA_SOURCE = NorthCarolinaPopulationExcelUntyped
    );
END
GO
SELECT * FROM dbo.NorthCarolinaPopulationExcelUntyped;