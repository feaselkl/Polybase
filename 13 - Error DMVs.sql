USE OOTP
GO
--When you experience query failure, the compute node errors
--DMV can provide you with some of the information you need.
SELECT TOP(100)
	e.error_id,
	e.source,
	e.type,
	e.create_time,
	e.compute_node_id,
	e.execution_id,
	e.spid,
	e.thread_id,
	e.details
FROM sys.dm_exec_compute_node_errors e
ORDER BY
	e.create_time DESC;