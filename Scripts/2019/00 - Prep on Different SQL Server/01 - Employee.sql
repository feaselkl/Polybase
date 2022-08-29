USE ForensicAccounting
GO
CREATE TABLE dbo.Employee
(
	EmployeeID INT IDENTITY(1,1) NOT NULL,
	FirstName NVARCHAR(50) NOT NULL,
	LastName NVARCHAR(50) NOT NULL,
	CONSTRAINT [PK_Employee] PRIMARY KEY(EmployeeID)
);

INSERT INTO dbo.Employee 
(
	FirstName,
	LastName
)
VALUES
(N'Jack', N'Aubrey'),
(N'Stephen', N'Maturin'),
(N'Sophia', N'Aubrey'),
(N'Diana', N'Villiers'),
(N'William', N'Babbington'),
(N'Barret', N'Bonden'),
(N'Nathaniel', N'Martin'),
(N'William', N'Mowett'),
(N'Ebenezer', N'Graham'),
(N'Molly', N'Harte'),
(N'Clarissa', N'Oakes'),
(N'Emily', N'Sweeting');
GO
