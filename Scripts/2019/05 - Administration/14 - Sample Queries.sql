USE [Scratch]
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = '<<SomeSecureKey>>';

-- Azure Blob Storage connection.
-- Review chapter 2 for the external data source, file format, and table details.
SELECT
    p.PopulationType,
    p.Year,
    SUM(p.Population) AS Population
FROM dbo.NorthCarolinaPopulation p
GROUP BY
    p.PopulationType,
    p.Year
ORDER BY
    p.Year DESC,
    p.PopulationType ASC;
GO

-- SQL Server connection.
SELECT
    li.LineItemDate,
	SUM(li.Amount) AS TotalAmount
FROM ELT.LineItem
GROUP BY
    li.LineItemDate
ORDER BY
    li.LineItemDate DESC;
GO

-- Cosmos DB connection.
SELECT * FROM dbo.Volcano;
GO

-- For each query, follow the flow:
-- Query external work to get the execution ID.
SELECT
    wk.execution_id,
    wk.input_name,
    wk.read_command,
    wk.[status]
FROM sys.dm_exec_external_work wk
ORDER BY
    execution_id DESC;
GO

-- Fill in the execution ID as needed.
DECLARE
    @execution_id SYSNAME = 'QID1122';

SELECT
    r.*
FROM sys.dm_exec_distributed_requests r
WHERE
    r.execution_id = @execution_id;

SELECT
    rs.execution_id,
    rs.step_index,
    rs.operation_type,
    rs.distribution_type,
    rs.location_type,
    --rs.[status],
    --rs.error_id,
    --rs.start_time,
    --rs.end_time,
    rs.total_elapsed_time,
    rs.row_count,
    rs.command
FROM sys.dm_exec_distributed_request_steps rs
WHERE
    rs.execution_id = @execution_id
ORDER BY
    step_index ASC;