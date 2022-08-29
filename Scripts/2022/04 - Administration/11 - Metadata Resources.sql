USE [Scratch]
GO

-- External data sources.
SELECT
    ds.data_source_id,
    ds.name,
    ds.[location],
    ds.type,
    ds.type_desc,
    ds.resource_manager_location,
    ds.credential_id,
    dsc.name AS database_scoped_credential_name,
    dsc.principal_id,
    dsc.credential_identity,
    -- Database name and shard map name are only for Azure SQL DB.
    -- This technically does not use PolyBase.
    --ds.database_name,
    --ds.shard_map_name,
    ds.connection_options,
    ds.pushdown
FROM sys.external_data_sources ds
    INNER JOIN sys.database_scoped_credentials dsc
        ON ds.credential_id = dsc.credential_id;
GO

-- External file formats
SELECT
    ff.file_format_id,
    ff.name,
    ff.format_type,
    ff.field_terminator,
    ff.string_delimiter,
    ff.date_format,
    ff.use_type_default,
    ff.serde_method,
    ff.row_terminator,
    ff.encoding,
    ff.[data_compression],
    ff.first_row
FROM sys.external_file_formats ff;
GO

-- External tables
SELECT
    t.object_id,
    t.name,
    t.schema_id,
    SCHEMA_NAME(t.schema_id) AS schema_name,
    t.type,
    -- There are several other sys.objects columns which show up here.
    t.data_source_id,
    t.file_format_id,
    t.[location],
    t.reject_type,
    t.reject_value,
    t.reject_sample_value,
    -- Distribution, sharding, and remote object columns are for
    -- Azure SQL DB and not PolyBase.
    t.rejected_row_location
FROM sys.external_tables t
ORDER BY
    t.name;
GO
