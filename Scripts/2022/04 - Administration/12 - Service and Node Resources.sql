USE [Scratch]
GO

-- Compute nodes
SELECT
    cn.compute_node_id,
    cn.type,
    cn.name,
    cn.address
FROM sys.dm_exec_compute_nodes cn;
GO

-- Compute node status
SELECT
    cns.compute_node_id,
    cns.process_id,
    cns.process_name,
    cns.allocated_memory,
    cns.available_memory,
    cns.process_cpu_usage,
    cns.total_cpu_usage,
    cns.thread_count,
    cns.handle_count,
    cns.total_elapsed_time,
    cns.is_available,
    cns.sent_time,
    cns.received_time,
    cns.error_id
FROM sys.dm_exec_compute_node_status cns;
GO

-- Compute node errors
SELECT
    cne.error_id,
    cne.source,
    cne.type,
    cne.create_time,
    cne.compute_node_id,
    cne.execution_id,
    cne.spid,
    cne.thread_id,
    cne.details
FROM sys.dm_exec_compute_node_errors cne
ORDER BY
    cne.create_time DESC;
GO

-- DMS services
SELECT
    ds.dms_core_id,
    ds.compute_node_id,
    ds.[status]
FROM sys.dm_exec_dms_services ds
ORDER BY
    ds.dms_core_id;
GO

-- DMS workers
SELECT
    dw.execution_id,
    dw.step_index,
    dw.dms_step_index,
    dw.compute_node_id,
    dw.distribution_id,
    dw.[type],
    dw.[status],
    dw.bytes_per_sec,
    dw.bytes_processed,
    dw.rows_processed,
    dw.start_time,
    dw.end_time,
    dw.total_elapsed_time,
    dw.cpu_time,
    dw.query_time,
    dw.buffers_available,
    dw.dms_cpid,
    dw.sql_spid,
    dw.error_id,
    dw.source_info,
    dw.destination_info,
    dw.command
FROM sys.dm_exec_dms_workers dw
ORDER BY execution_id;
GO
