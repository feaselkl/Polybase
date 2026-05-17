-- S3-compatible object storage. The docker-compose stack runs MinIO
-- on hostname `s3` over HTTPS port 9000 with a self-signed cert mounted
-- at the SQL Server runtime trust path
-- (/var/opt/mssql/security/ca-certificates/), so PolyBase trusts it
-- without rebuilding the image.
--
-- S3Credential is created automatically at first boot of the Docker stack
-- from S3_ACCESS_KEY / S3_SECRET_KEY in .env. For non-container runs, see
-- 00 - Setup and Teardown/02 - Create Credentials.sql.
--
-- Do *not* include the bucket name in the LOCATION; that goes in the
-- external table definition.

USE [Scratch];
GO

OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';
GO

IF NOT EXISTS
(
    SELECT 1 FROM sys.external_data_sources
    WHERE name = N'S3Storage'
)
BEGIN
    CREATE EXTERNAL DATA SOURCE S3Storage WITH
    (
        LOCATION   = 's3://s3:9000/',
        CREDENTIAL = S3Credential
    );
END
GO
