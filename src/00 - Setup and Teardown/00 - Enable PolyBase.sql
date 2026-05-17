USE [master]
GO
-- NOTE: if you are using the Docker Compose process to build
-- demo containers, you do *not* need to run this script.

--Only necessary if you are using ODBC.
--If only using API capabilities, PolyBase is not needed.
EXEC sp_configure
	@configname = 'polybase enabled',
	@configvalue = 1;
GO
RECONFIGURE;
GO
--Necessary if we want to use PolyBase to export data to external tables.
--Not needed for read-only access.
EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE
GO
EXEC sp_configure
	@configname = 'allow polybase export',
	@configvalue = 1;
GO
RECONFIGURE;
GO
-- Now restart the SQL Server database engine service, as well
-- as the two PolyBase services.