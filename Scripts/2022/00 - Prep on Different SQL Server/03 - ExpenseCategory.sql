USE [ForensicAccounting]
GO
CREATE TABLE dbo.ExpenseCategory
(
	ExpenseCategoryID TINYINT NOT NULL,
	ExpenseCategory NVARCHAR(120) NOT NULL,
	CONSTRAINT [PK_ExpenseCategory] PRIMARY KEY CLUSTERED (ExpenseCategoryID),
	CONSTRAINT [UKC_ExpenseCategory] UNIQUE (ExpenseCategory)
);

INSERT INTO dbo.ExpenseCategory
(
	ExpenseCategoryID,
	ExpenseCategory
)
VALUES
(1, N'Vehicle repair labor'),
(2, N'Vehicle maintenance labor'),
(3, N'Fuel'),
(4, N'Lights & Reflectors'),
(5, N'Switches'),
(6, N'Electrical'),
(7, N'Signs & Decals'),
(8, N'Mirrors'),
(9, N'Heater & Defroster'),
(10, N'Stop Arms, Crossing Gates & Hatches'),
(11, N'Safety Equipment (1st Aid)'),
(12, N'Seats & Seat Belts'),
(13, N'Radio / PA'),
(14, N'Video Camera/Check Systems'),
(15, N'Seat Repair'),
(16, N'Child Seats & Restraints'),
(17, N'Wheelchair Tie-Downs'),
(18, N'Glass, Windshields & Windows'),
(19, N'Windshield Wipers & Parts'),
(20, N'Bus Accessories & Cleaning Tools'),
(21, N'Thermal Heaters'),
(22, N'Wheelchair Lift & Mobility'),
(23, N'Body Accessories'),
(24, N'OEM Body Parts'),
(25, N'Brakes'),
(26, N'Suspension'),
(27, N'Filters'),
(28, N'Exhaust');