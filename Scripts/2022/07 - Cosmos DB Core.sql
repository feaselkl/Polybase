USE [Scratch]
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

-- Note that we do NOT use a database-scoped credential for this
-- Instead, we need to include AuthenticationKey in the definition
IF NOT EXISTS
(
    SELECT 1
    FROM sys.external_data_sources ds
    WHERE
        ds.name = N'CosmosCore'
)
BEGIN
    CREATE EXTERNAL DATA SOURCE CosmosCore WITH
    (
        LOCATION = 'odbc://cspolybasecore.documents.azure.com:443/',
        CONNECTION_OPTIONS = 'Driver={Microsoft Azure DocumentDB ODBC Driver};Host={https://cspolybasecore.documents.azure.com:443};AuthenticationKey={<Your Auth Key>}'
    );
END
GO
-- SECURITY RISK!
SELECT * FROM sys.external_data_sources WHERE name = N'CosmosCore'
GO

/* Alternative route:  set up a DSN first */
DROP EXTERNAL DATA SOURCE CosmosCore;

IF NOT EXISTS
(
    SELECT 1
    FROM sys.external_data_sources ds
    WHERE
        ds.name = N'CosmosCore'
)
BEGIN
    CREATE EXTERNAL DATA SOURCE CosmosCore WITH
    (
		-- Only the "odbc" is relevant; otherwise, location can be anything.
        LOCATION = 'odbc://MACCLOUD/',
        CONNECTION_OPTIONS = 'DSN=CosmosCore'
    );
END
GO
IF NOT EXISTS
(
    SELECT 1
    FROM sys.external_tables t
    WHERE
        t.name = N'EmployeeCore'
)
BEGIN
    CREATE EXTERNAL TABLE dbo.EmployeeCore
    (
        _rid NVARCHAR(100) NOT NULL,
		FirstName NVARCHAR(50) NOT NULL,
		LastName NVARCHAR(50) NOT NULL
    )
    WITH
    (
        LOCATION='Employee',
        DATA_SOURCE = CosmosCore
    );
END
GO
-- "The current ODBC driver doesn't support aggregate pushdowns" via https://docs.microsoft.com/en-us/azure/cosmos-db/sql/odbc-driver
SELECT * FROM dbo.EmployeeCore;
SELECT COUNT(*) FROM dbo.EmployeeCore;
SELECT COUNT(*) FROM dbo.EmployeeCore where lastname = 'Aubrey';
SELECT COUNT(*) FROM dbo.EmployeeCore where lastname = 'Aubrey' option(force externalpushdown);
GO