USE OOTP
GO
/* We can use these DMVs to review
what happened in our MapReduce Hadoop query.
Because of the MapReduce job, there is an additional
useful DMV. */

--First, find recently completed work.
SELECT
	*
FROM sys.dm_exec_external_work d
ORDER BY
	d.start_time DESC;

--This view shows us some basic stats for the entire request.
--Note that things like querying DMVs will increment the execution ID!
SELECT
	*
FROM sys.dm_exec_distributed_requests r
WHERE
	r.execution_id = 'QID248';

--Now get details on the execution.
SELECT
	*
FROM sys.dm_exec_distributed_request_steps rs
WHERE
	rs.execution_id = 'QID248'
ORDER BY
	rs.step_index;

SELECT
	*
FROM sys.dm_exec_external_operations o
WHERE
	o.execution_id = 'QID248';
GO
