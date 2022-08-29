USE [ForensicAccounting]
GO
CREATE TABLE dbo.Vendor
(
	VendorID INT IDENTITY (1, 1) NOT NULL,
	VendorName NVARCHAR(100) NOT NULL,
	CONSTRAINT [PK_Vendor] PRIMARY KEY CLUSTERED (VendorID),
	CONSTRAINT [UKC_Vendor] UNIQUE (VendorName)
);

INSERT INTO dbo.Vendor 
(
	VendorName
)
VALUES
(N'Bus Repair Shack'),
(N'VehiCo Parts and Accessories'),
(N'Fuel Suppliers, Ltd'),
(N'Fuel Associates, Unlimited'),
(N'Glass and Sons Glass and Accessories'),
(N'Electronics and Repairs'),
(N'Clean Sweep Cleaning Supplies'),
(N'Engine Mates'),
(N'Safety First'),
(N'Mobility Accessories R Us'),
(N'Tony''s Bus Fixer Uppers'),
(N'Tony''s Fixer Upper Buses'),
(N'Comfort Rider, GmbH'),
(N'Doodads and Thingies, Inc.'),
(N'The Longevity Crew');
GO
