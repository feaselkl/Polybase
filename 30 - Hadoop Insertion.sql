USE OOTP
GO
--To insert data, first we need to make sure that
--Polybase insertion is turned on.
EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE
GO
EXEC sp_configure 'allow polybase export', 1;
GO
RECONFIGURE
GO

--Then we will create a new table.  This way we can test
--insertion without fouling up our existing table.
--Note the location:  it's a folder, not a file!
--Also, this folder might already need to exist in Hadoop.
--If you get an error trying to load, try creating the folder.
CREATE EXTERNAL TABLE [dbo].[SecondBasemenTest]
(
	[FirstName] [VARCHAR](50) NULL,
	[LastName] [VARCHAR](50) NULL,
	[Age] [INT] NULL,
	[Throws] [VARCHAR](5) NULL,
	[Bats] [VARCHAR](5) NULL
)
WITH
(
	DATA_SOURCE = [HDP],
	LOCATION = N'/tmp/ootp/SecondBasemenTest/',
	FILE_FORMAT = [TextFileFormat],
	REJECT_TYPE = VALUE,
	REJECT_VALUE = 5
);
GO

--Insert values into the new table.
INSERT INTO dbo.SecondBasemenTest
(
	FirstName,
	LastName,
	Age,
	Throws,
	Bats
)
SELECT
	sb.FirstName,
	sb.LastName,
	sb.Age,
	sb.Bats,
	sb.Throws
FROM Player.SecondBasemen sb;

--Over in Ambari, we can see that Polybase created several files.
--We can see that Polybase will create new files for each load.
INSERT INTO dbo.SecondBasemenTest
(
	FirstName,
	LastName,
	Age,
	Throws,
	Bats
)
SELECT
	sb.FirstName,
	sb.LastName,
	sb.Age,
	sb.Bats,
	sb.Throws
FROM Player.SecondBasemen sb
	CROSS JOIN Player.SecondBasemen sb1;
GO
