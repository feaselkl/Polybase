USE [Scratch]
GO
-- A sample query to load a dimension.
SELECT
	vec.VendorID,
	v.VendorName,
	vec.ExpenseCategoryID,
	ec.ExpenseCategory
FROM ELT.VendorExpenseCategory vec
	INNER JOIN ELT.Vendor v
		ON vec.VendorID = v.VendorID
	INNER JOIN ELT.ExpenseCategory ec
		ON vec.ExpenseCategoryID = ec.ExpenseCategoryID;
GO
-- A sample query to get line items since our last load.
DECLARE
	@LastLoadDate DATE = '2018-06-18';

SELECT
	li.*
FROM ELT.LineItem li
WHERE
	li.LineItemDate > @LastLoadDate;