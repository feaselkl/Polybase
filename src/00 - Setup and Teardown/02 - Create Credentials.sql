-- Database scoped credentials needed by the demo data sources.
-- Container users: skip this script — infra/docker/sqlserver/init/03-create-credentials.sql.tmpl
-- runs at first boot and creates these from .env.
-- Non-container users: replace each placeholder with the real value
-- (Azure portal SAS, Cosmos primary key, etc.) before running.

USE Scratch;
GO

OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

-- Cosmos DB. IDENTITY = Cosmos account user; SECRET = primary or secondary key.
IF NOT EXISTS (SELECT 1 FROM sys.database_scoped_credentials WHERE name = N'CosmosCredential')
BEGIN
    CREATE DATABASE SCOPED CREDENTIAL CosmosCredential
    WITH IDENTITY = '<Cosmos account user>',
         SECRET   = '<Cosmos account key>';
END
GO

-- Azure Blob Storage. SAS token, no leading '?'.
IF NOT EXISTS (SELECT 1 FROM sys.database_scoped_credentials WHERE name = N'AzureStorageCredential')
BEGIN
    CREATE DATABASE SCOPED CREDENTIAL AzureStorageCredential
    WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
         SECRET   = '<Blob SAS>';
END
GO

-- Azure Data Lake Storage Gen2. SAS token, no leading '?'.
IF NOT EXISTS (SELECT 1 FROM sys.database_scoped_credentials WHERE name = N'DataLakeCredential')
BEGIN
    CREATE DATABASE SCOPED CREDENTIAL DataLakeCredential
    WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
         SECRET   = '<ADLS SAS>';
END
GO

-- PostgreSQL volcano sidecar. Match the values in your Postgres deployment.
IF NOT EXISTS (SELECT 1 FROM sys.database_scoped_credentials WHERE name = N'PostgresVolcanoCredential')
BEGIN
    CREATE DATABASE SCOPED CREDENTIAL PostgresVolcanoCredential
    WITH IDENTITY = '<Postgres user>',
         SECRET   = '<Postgres password>';
END
GO

-- Second SQL Server instance (federated read demo). Match the login on the remote.
IF NOT EXISTS (SELECT 1 FROM sys.database_scoped_credentials WHERE name = N'RemoteSqlCredential')
BEGIN
    CREATE DATABASE SCOPED CREDENTIAL RemoteSqlCredential
    WITH IDENTITY = '<Remote SQL login>',
         SECRET   = '<Remote SQL password>';
END
GO

-- S3-compatible object storage. SECRET is '<access-key>:<secret-key>'.
IF NOT EXISTS (SELECT 1 FROM sys.database_scoped_credentials WHERE name = N'S3Credential')
BEGIN
    CREATE DATABASE SCOPED CREDENTIAL S3Credential
    WITH IDENTITY = 'S3 Access Key',
         SECRET   = '<S3 access key>:<S3 secret key>';
END
GO
