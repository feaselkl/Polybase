-- Cosmos DB (MongoDB API) external data source. Used by the volcano demo
-- to read the VolcanoData collection.
--
-- CosmosCredential is created automatically at first boot of the Docker
-- stack from COSMOS_USER / COSMOS_KEY in .env. For non-container runs,
-- see 00 - Setup and Teardown/02 - Create Credentials.sql.

USE [Scratch];
GO

OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.external_data_sources
    WHERE name = N'CosmosDB'
)
BEGIN
    CREATE EXTERNAL DATA SOURCE CosmosDB WITH
    (
        LOCATION           = 'mongodb://cspolybase.mongo.cosmos.azure.com:10255',
        CONNECTION_OPTIONS = 'ssl=true',
        CREDENTIAL         = CosmosCredential,
        PUSHDOWN           = ON
    );
END
GO
