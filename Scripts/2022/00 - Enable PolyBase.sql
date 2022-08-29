USE [master]
GO
EXEC sp_configure
	@configname = 'polybase enabled',
	@configvalue = 1;
GO
RECONFIGURE;
GO
--To insert data, first we need to make sure that
--PolyBase insertion is turned on.
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