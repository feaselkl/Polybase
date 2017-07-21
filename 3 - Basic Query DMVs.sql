USE OOTP
GO
/* We can use these DMVs to review
what happened in our basic Hadoop query.
For the basic query, only a few DMVs
are important. */

--First, find recently completed work.
SELECT
	*
FROM sys.dm_exec_external_work d
ORDER BY
	d.start_time DESC;

--This view shows us some basic stats for the entire request.
SELECT
	*
FROM sys.dm_exec_distributed_requests r
WHERE
	r.execution_id = 'QID243';

--Now get details on the execution.
SELECT
	*
FROM sys.dm_exec_distributed_request_steps rs
WHERE
	rs.execution_id = 'QID243'
ORDER BY
	rs.step_index;
GO
