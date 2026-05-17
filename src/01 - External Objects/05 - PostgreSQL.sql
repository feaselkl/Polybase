-- PostgreSQL via the SQL Server 2025 generic ODBC connector on Linux.
-- Used by the volcano demo to enrich the federated query with the
-- volcano_type description lookup.
--
-- PostgresVolcanoCredential is created automatically at first boot of
-- the Docker stack from POSTGRES_USER / POSTGRES_PASSWORD in .env. For
-- non-container runs, see 00 - Setup and Teardown/02 - Create Credentials.sql.
--
-- The 'PostgresVolcano' DSN is registered in /etc/odbc.ini inside the
-- SQL Server container (see infra/docker/sqlserver/odbc.ini). PolyBase's
-- ODBC connector on Linux requires the DSN entry — Driver={...} inline
-- in CONNECTION_OPTIONS isn't enough. The DSN supplies the hostname,
-- port, and database; CONNECTION_OPTIONS just names the DSN.

USE [Scratch];
GO

OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.external_data_sources
    WHERE name = N'Postgres'
)
BEGIN
    CREATE EXTERNAL DATA SOURCE Postgres WITH
    (
        LOCATION           = 'odbc://postgres:5432',
        CONNECTION_OPTIONS = 'DSN=PostgresVolcano;',
        CREDENTIAL         = PostgresVolcanoCredential,
        PUSHDOWN           = ON
    );
END
GO
