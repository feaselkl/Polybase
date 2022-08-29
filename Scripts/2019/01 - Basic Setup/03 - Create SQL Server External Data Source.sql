-- This is an example of creating an external data source which connects
-- to a SQL Server instance.  Change the name Desktop to your instance
-- name.  You will also need to change (or create) the PolyBaseUser login
-- and fill in a password.

USE [Scratch]
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO
IF NOT EXISTS
(
	SELECT 1
	FROM sys.database_scoped_credentials dsc
	WHERE
		dsc.name = N'DesktopCredentials'
)
BEGIN
	CREATE DATABASE SCOPED CREDENTIAL DesktopCredentials
	WITH IDENTITY = 'PolyBaseUser', Secret = '<<Some Password>>';
END
GO
IF NOT EXISTS
(
	SELECT 1
	FROM sys.external_data_sources e
	WHERE
		e.name = N'Desktop'
)
BEGIN
	CREATE EXTERNAL DATA SOURCE Desktop WITH
	(
		LOCATION = 'sqlserver://192.168.100.110',
		PUSHDOWN = ON,
		CREDENTIAL = DesktopCredentials
	);
END
GO