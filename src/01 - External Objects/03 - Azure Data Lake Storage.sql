-- Azure Data Lake Storage Gen2 external data source. Used by the NC
-- population demos (Cities CSV, County CSV, Unemployment Parquet).
--
-- DataLakeCredential is created automatically at first boot of the
-- Docker stack from AZURE_ADLS_SAS in .env. For non-container runs, see
-- 00 - Setup and Teardown/02 - Create Credentials.sql.
--
-- Update the LOCATION below to match your ADLS Gen2 account/container.
-- The 'adls://' scheme is the ADLS Gen2 native endpoint.

USE [Scratch];
GO

OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.external_data_sources
    WHERE name = N'AzureDataLakeStorage'
)
BEGIN
    CREATE EXTERNAL DATA SOURCE AzureDataLakeStorage WITH
    (
        LOCATION   = 'adls://ncpop@bdadatalake.dfs.core.windows.net',
        CREDENTIAL = DataLakeCredential
    );
END
GO
