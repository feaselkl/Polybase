-- Auto-applied on first container start. After this script runs the entrypoint
-- restarts SQL Server so the PolyBase service comes up enabled.
USE [master];
GO
EXEC sp_configure 'polybase enabled', 1;
RECONFIGURE;
GO
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
EXEC sp_configure 'allow polybase export', 1;
RECONFIGURE;
GO
