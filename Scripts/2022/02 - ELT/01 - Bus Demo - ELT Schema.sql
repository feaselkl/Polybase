USE [Scratch]
GO
IF (SCHEMA_ID('ELT') IS NULL)
BEGIN
	-- Creating a schema must be the first statmeent in a batch, so
	-- to safely run this, we need to wrap it in dynamic SQL.
	EXEC (N'CREATE SCHEMA ELT;');
END
GO
