USE [master]
GO
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
-- Now restart the SQL Server database engine service, as well
-- as the two PolyBase services.