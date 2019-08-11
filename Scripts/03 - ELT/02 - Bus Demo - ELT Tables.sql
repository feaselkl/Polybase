USE [Scratch]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO
-- Create all of the external tables in one fell swoop.
IF (OBJECT_ID('ELT.Employee') IS NULL)
BEGIN
	CREATE EXTERNAL TABLE ELT.Employee
	(
		EmployeeID INT NOT NULL,
		FirstName NVARCHAR(50) NOT NULL,
		LastName NVARCHAR(50) NOT NULL
	)
	WITH
	(
		LOCATION = 'ForensicAccounting.dbo.Employee',
		DATA_SOURCE = Desktop
	);
END

IF (OBJECT_ID('ELT.Bus') IS NULL)
BEGIN
	CREATE EXTERNAL TABLE ELT.Bus
	(
		BusID INT NOT NULL,
		DateFirstInService DATE NOT NULL,
		DateRetired DATE NULL
	)
	WITH
	(
		LOCATION = 'ForensicAccounting.dbo.Bus',
		DATA_SOURCE = Desktop
	);
END

IF (OBJECT_ID('ELT.Calendar') IS NULL)
BEGIN
	CREATE EXTERNAL TABLE ELT.Calendar
	(
		DateKey INT NOT NULL,
		[Date] DATE NOT NULL,
		[Day] TINYINT NOT NULL,
		DayOfWeek TINYINT NOT NULL,
		DayName VARCHAR(10) NOT NULL,
		IsWeekend BIT NOT NULL,
		DayOfWeekInMonth TINYINT NOT NULL,
		CalendarDayOfYear SMALLINT NOT NULL,
		WeekOfMonth TINYINT NOT NULL,
		CalendarWeekOfYear TINYINT NOT NULL,
		CalendarMonth TINYINT NOT NULL,
		MonthName VARCHAR(10) NOT NULL,
		CalendarQuarter TINYINT NOT NULL,
		CalendarQuarterName CHAR(2) NOT NULL,
		CalendarYear INT NOT NULL,
		FirstDayOfMonth DATE NOT NULL,
		LastDayOfMonth DATE NOT NULL,
		FirstDayOfWeek DATE NOT NULL,
		LastDayOfWeek DATE NOT NULL,
		FirstDayOfQuarter DATE NOT NULL,
		LastDayOfQuarter DATE NOT NULL,
		CalendarFirstDayOfYear DATE NOT NULL,
		CalendarLastDayOfYear DATE NOT NULL,
		FirstDayOfNextMonth DATE NOT NULL,
		CalendarFirstDayOfNextYear DATE NOT NULL,
		FiscalDayOfYear SMALLINT NOT NULL,
		FiscalWeekOfYear TINYINT NOT NULL,
		FiscalMonth TINYINT NOT NULL,
		FiscalQuarter TINYINT NOT NULL,
		FiscalQuarterName CHAR(2) NOT NULL,
		FiscalYear INT NOT NULL,
		FiscalFirstDayOfYear DATE NOT NULL,
		FiscalLastDayOfYear DATE NOT NULL,
		FiscalFirstDayOfNextYear DATE NOT NULL
	)
	WITH
	(
		LOCATION = 'ForensicAccounting.dbo.Calendar',
		DATA_SOURCE = Desktop
	);
END

IF (OBJECT_ID('ELT.ExpenseCategory') IS NULL)
BEGIN
	CREATE EXTERNAL TABLE ELT.ExpenseCategory
	(
		ExpenseCategoryID TINYINT NOT NULL,
		ExpenseCategory NVARCHAR(120) NOT NULL
	)
	WITH
	(
		LOCATION = 'ForensicAccounting.dbo.ExpenseCategory',
		DATA_SOURCE = Desktop
	);
END

IF (OBJECT_ID('ELT.Vendor') IS NULL)
BEGIN
	CREATE EXTERNAL TABLE ELT.Vendor
	(
		VendorID INT NOT NULL,
		VendorName NVARCHAR(100) NOT NULL
	)
	WITH
	(
		LOCATION = 'ForensicAccounting.dbo.Vendor',
		DATA_SOURCE = Desktop
	);
END

IF (OBJECT_ID('ELT.VendorExpenseCategory') IS NULL)
BEGIN
	CREATE EXTERNAL TABLE ELT.VendorExpenseCategory
	(
		VendorID INT NOT NULL,
		ExpenseCategoryID TINYINT NOT NULL
	)
	WITH
	(
		LOCATION = 'ForensicAccounting.dbo.VendorExpenseCategory',
		DATA_SOURCE = Desktop
	);
END

IF (OBJECT_ID('ELT.LineItem') IS NULL)
BEGIN
	CREATE EXTERNAL TABLE ELT.LineItem
	(
		LineItemID INT NOT NULL,
		BusID INT NOT NULL,
		VendorID INT NOT NULL,
		ExpenseCategoryID TINYINT NOT NULL,
		EmployeeID INT NOT NULL,
		LineItemDate DATE NOT NULL,
		Amount DECIMAL(13, 2) NOT NULL
	)
	WITH
	(
		LOCATION = 'ForensicAccounting.dbo.LineItem',
		DATA_SOURCE = Desktop
	);
END
GO
