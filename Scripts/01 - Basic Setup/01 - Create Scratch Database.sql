USE [master]
GO
IF (DB_ID('Scratch') IS NULL)
BEGIN
	CREATE DATABASE Scratch
END
GO
USE Scratch
GO
-- Now we need to create a database master key if we do not have one already.
IF NOT EXISTS
(
	SELECT 1
	FROM sys.symmetric_keys
	WHERE
		name LIKE '%DatabaseMasterKey%'
)
BEGIN
	CREATE MASTER KEY ENCRYPTION BY PASSWORD = '<<SomeSecureKey>>';
END
GO
-- Enable PolyBase.  Then restart the SQL Server engine and PolyBase components.
EXEC sp_configure
@configname = 'polybase enabled',
@configvalue = 1;
GO
RECONFIGURE;
GO
EXEC sp_configure
@configname = 'hadoop connectivity',
@configvalue = 7;
GO
RECONFIGURE
GO
