-- This is an example of creating an external data source which connects
-- to a SQL Server instance.  Change the name SQLCONTROL to your instance
-- name.  You will also need to change (or create) the PolyBaseUser login
-- and fill in a password.

USE [Scratch]
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO
IF (OBJECT_ID('dbo.RemoteEmployee') IS NULL)
BEGIN
	CREATE EXTERNAL TABLE [dbo].[RemoteEmployee]
	(
		EmployeeID INT NOT NULL,
		FirstName NVARCHAR(50) NOT NULL,
		LastName NVARCHAR(50) NOT NULL
	)
	WITH
	(
		DATA_SOURCE = Desktop,
		LOCATION = 'ForensicAccounting.dbo.Employee'
	);
END
GO

SELECT
	r.EmployeeID,
	r.FirstName,
	r.LastName
FROM dbo.RemoteEmployee r;
GO