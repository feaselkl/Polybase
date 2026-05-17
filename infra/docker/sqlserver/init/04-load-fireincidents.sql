-- Cold-storage demo source table. Loaded on first boot from the CSV the
-- parquet-to-csv builder stage produced in the image. Dropped and recreated
-- on each fresh init so `docker compose down -v + up` gives a clean load.

USE Scratch;
GO

IF (OBJECT_ID('dbo.RaleighFireIncidents', 'U') IS NOT NULL)
    DROP TABLE dbo.RaleighFireIncidents;
GO

CREATE TABLE dbo.RaleighFireIncidents
(
    incident_number            NVARCHAR(20)  NULL,
    incident_type              INT           NULL,
    incident_type_description  NVARCHAR(100) NULL,
    arrive_date_time           DATETIME2(0)  NULL,
    cleared_date_time          DATETIME2(0)  NULL,
    dispatch_date_time         DATETIME2(0)  NULL,
    exposure                   INT           NULL,
    platoon                    NVARCHAR(5)   NULL,
    station                    INT           NULL,
    address                    NVARCHAR(150) NULL,
    address2                   NVARCHAR(150) NULL,
    apt_room                   NVARCHAR(50)  NULL
);
GO

BULK INSERT dbo.RaleighFireIncidents
FROM '/var/opt/mssql/data-shared/RaleighFireIncidents.csv'
WITH
(
    FORMAT          = 'CSV',
    FIRSTROW        = 2,
    FIELDQUOTE      = '"',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '0x0a',
    TABLOCK
);
GO
