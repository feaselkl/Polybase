-- Bootstrap for the second SQL Server instance. Creates the ExternalExample
-- database that holds the eruption fact table queried by the primary's
-- federated demo.

USE [master];
GO

IF (DB_ID('ExternalExample') IS NULL)
BEGIN
    CREATE DATABASE ExternalExample;
END
GO
