-- File formats are decoupled from data sources: one format definition
-- can be reused across Blob, ADLS, and S3 external tables. These four
-- cover every demo in this talk.

USE [Scratch];
GO

-- Plain comma-separated, no header row. Used when the source file has
-- no header (raw extracts).
IF NOT EXISTS
(
    SELECT 1 FROM sys.external_file_formats
    WHERE name = N'CsvFileFormat'
)
BEGIN
    CREATE EXTERNAL FILE FORMAT CsvFileFormat WITH
    (
        FORMAT_TYPE = DELIMITEDTEXT,
        FORMAT_OPTIONS
        (
            FIELD_TERMINATOR = N',',
            USE_TYPE_DEFAULT = True,
            STRING_DELIMITER = '"',
            ENCODING = 'UTF8'
        )
    );
END
GO

-- Comma-separated with a header row to skip. The NC population CSVs use this.
IF NOT EXISTS
(
    SELECT 1 FROM sys.external_file_formats
    WHERE name = N'CsvFileFormatWithHeader'
)
BEGIN
    CREATE EXTERNAL FILE FORMAT CsvFileFormatWithHeader WITH
    (
        FORMAT_TYPE = DELIMITEDTEXT,
        FORMAT_OPTIONS
        (
            FIELD_TERMINATOR = N',',
            FIRST_ROW = 2,
            USE_TYPE_DEFAULT = True,
            STRING_DELIMITER = '"',
            ENCODING = 'UTF8'
        )
    );
END
GO

-- factbook.csv (CIA World Factbook) ships with semicolons as separators.
-- The volcano demo joins against it for country-level enrichments.
IF NOT EXISTS
(
    SELECT 1 FROM sys.external_file_formats
    WHERE name = N'SemiColonFileFormat'
)
BEGIN
    CREATE EXTERNAL FILE FORMAT SemiColonFileFormat WITH
    (
        FORMAT_TYPE = DELIMITEDTEXT,
        FORMAT_OPTIONS
        (
            FIELD_TERMINATOR = N';',
            USE_TYPE_DEFAULT = False,
            STRING_DELIMITER = '"',
            ENCODING = 'UTF8'
        )
    );
END
GO

-- Snappy-compressed Parquet. Used for the unemployment data (read) and
-- the volcano CETAS export (write).
IF NOT EXISTS
(
    SELECT 1 FROM sys.external_file_formats
    WHERE name = N'ParquetFileFormat'
)
BEGIN
    CREATE EXTERNAL FILE FORMAT ParquetFileFormat WITH
    (
        FORMAT_TYPE = PARQUET,
        DATA_COMPRESSION = 'org.apache.hadoop.io.compress.SnappyCodec'
    );
END
GO
