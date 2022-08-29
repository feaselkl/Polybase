USE [ForensicAccounting]
GO
CREATE TABLE dbo.VendorExpenseCategory
(
	VendorID INT NOT NULL,
	ExpenseCategoryID TINYINT NOT NULL,
	CONSTRAINT [PK_VendorExpenseCategory] PRIMARY KEY CLUSTERED (VendorID, ExpenseCategoryID)
);

INSERT INTO dbo.VendorExpenseCategory 
(
	VendorID,
	ExpenseCategoryID
)
VALUES
(1, 1),
(1, 2),
(2, 5),
(2, 6),
(2, 7),
(2, 12),
(2, 13),
(2, 16),
(2, 17),
(3, 3),
(4, 3),
(5, 4),
(5, 8),
(5, 18),
(5, 19),
(6, 5),
(6, 6),
(6, 13),
(6, 14),
(7, 7),
(7, 17),
(7, 19),
(7, 20),
(7, 27),
(7, 28),
(8, 9),
(8, 21),
(8, 24),
(8, 25),
(8, 26),
(8, 27),
(8, 28),
(9, 4),
(9, 5),
(9, 7),
(9, 8),
(9, 10),
(9, 11),
(9, 12),
(9, 15),
(9, 17),
(9, 21),
(9, 22),
(9, 23),
(10, 16),
(10, 17),
(10, 22),
(10, 23),
(11, 1),
(11, 2),
(11, 24),
(12, 9),
(12, 12),
(12, 13),
(12, 15),
(12, 19),
(12, 21),
(12, 25),
(12, 27),
(13, 9),
(13, 11),
(13, 12),
(13, 15),
(13, 16),
(13, 21),
(14, 7),
(14, 9),
(14, 14),
(14, 17),
(14, 22),
(14, 23),
(14, 28),
(15, 2);