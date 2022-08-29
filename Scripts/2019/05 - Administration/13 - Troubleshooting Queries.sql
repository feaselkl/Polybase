USE [Scratch]
GO

-- External work
SELECT
    wk.execution_id,
    wk.step_index,
    wk.dms_step_index,
    wk.work_id,
    wk.compute_node_id,
    wk.type,
    wk.input_name,
    wk.read_location,
    wk.read_command,
    wk.bytes_processed,
    wk.length,
    wk.start_time,
    wk.end_time,
    wk.total_elapsed_time,
    wk.[status]
FROM sys.dm_exec_external_work wk;
GO

-- External operations
SELECT
    op.execution_id,
    op.step_index,
    op.operation_type,
    op.operation_name,
    op.map_progress,
    op.reduce_progress
FROM sys.dm_exec_external_operations op;
GO

-- Distributed requests
SELECT
    r.sql_handle,
    r.execution_id,
    r.status,
    r.error_id,
    r.start_time,
    r.end_time,
    r.total_elapsed_time
FROM sys.dm_exec_distributed_requests r;
GO

-- Find queries for each PolyBase request whose plan is in the cache.
SELECT
    r.execution_id,
    r.status,
    r.error_id,
    r.start_time,
    r.end_time,
    r.total_elapsed_time,
    t.text
FROM sys.dm_exec_distributed_requests r
    CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
ORDER BY
    r.end_time DESC;
GO

-- Distributed request steps
SELECT
    rs.execution_id,
    rs.step_index,
    rs.operation_type,
    rs.distribution_type,
    rs.location_type,
    rs.[status],
    rs.error_id,
    rs.start_time,
    rs.end_time,
    rs.total_elapsed_time,
    rs.row_count,
    rs.command
FROM sys.dm_exec_distributed_request_steps rs
ORDER BY
    rs.execution_id DESC,
    rs.step_index ASC;
GO

-- Distributed SQL requests
-- Change the execution_id value to a legitimate execution ID.
SELECT
    rs.execution_id,
    rs.step_index,
    rs.compute_node_id,
    rs.distribution_id,
    rs.[status],
    rs.error_id,
    rs.start_time,
    rs.end_time,
    rs.total_elapsed_time,
    rs.row_count,
    rs.spid,
    rs.command
FROM sys.dm_exec_distributed_sql_requests rs
WHERE
    execution_id = 'QID2148'
ORDER BY
    execution_id,
    step_index,
    compute_node_id,
    distribution_id;
GO