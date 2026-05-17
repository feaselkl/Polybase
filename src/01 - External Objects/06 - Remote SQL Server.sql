-- Second SQL Server instance, target of the federated-read demo. Used by
-- the volcano demo to read dbo.Eruption out of ExternalExample on the
-- sqlserver-remote container.
--
-- RemoteSqlCredential is created automatically at first boot of the Docker
-- stack from REMOTE_SQL_USER / REMOTE_SQL_PASSWORD in .env. For non-container
-- runs, see 00 - Setup and Teardown/02 - Create Credentials.sql.
--
-- Hostname 'sqlserver-remote' resolves on the docker-compose network. The
-- internal port is 1433; the external port (mapped on the host) is 31433
-- so it doesn't collide with the primary instance.

USE [Scratch];
GO

OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.external_data_sources
    WHERE name = N'RemoteSQLServer'
)
BEGIN
    CREATE EXTERNAL DATA SOURCE RemoteSQLServer WITH
    (
        LOCATION   = 'sqlserver://sqlserver-remote:1433',
        PUSHDOWN   = ON,
        CREDENTIAL = RemoteSqlCredential
    );
END
GO
