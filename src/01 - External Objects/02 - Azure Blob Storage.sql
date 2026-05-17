-- Azure Blob Storage external data source. Used by:
--   * the volcano demo (factbook.csv country enrichment)
--   * CETAS export of the federated volcano result set
--
-- AzureStorageCredential is created automatically at first boot of the
-- Docker stack from AZURE_BLOB_SAS in .env. For non-container runs, see
-- 00 - Setup and Teardown/02 - Create Credentials.sql.
-- Note that you will need to change the locationt to match your storage
-- account and container.

USE [Scratch];
GO

OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.external_data_sources
    WHERE name = N'AzureBlobStorage'
)
BEGIN
    CREATE EXTERNAL DATA SOURCE AzureBlobStorage WITH
    (
        LOCATION   = 'abs://ncpop@cspolybaseblob.blob.core.windows.net',
        CREDENTIAL = AzureStorageCredential
    );
END
GO
