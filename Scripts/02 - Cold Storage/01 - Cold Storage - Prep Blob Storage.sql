USE [Scratch]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO
-- Set up the storage blob if it does not already exist.
-- We'll use the same storage container as visits data from earlier,
-- but you can certainly change this.
IF NOT EXISTS
(
	SELECT 1
	FROM sys.external_data_sources eds
	WHERE
		eds.name = N'AzureFireIncidentsBlob'
)
BEGIN
	CREATE EXTERNAL DATA SOURCE AzureFireIncidentsBlob WITH
	(
		TYPE = HADOOP,
		LOCATION = 'wasbs://visits@cspolybaseblob.blob.core.windows.net',
		CREDENTIAL = AzureStorageCredential
	);
END
GO
