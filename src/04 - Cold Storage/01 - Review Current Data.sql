USE [Scratch]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SELECT TOP(100) *
FROM dbo.RaleighFireIncidents;
GO
-- Incidents broken out into multiple years.
-- There are also some incidents with missing dispatch_date_time.
SELECT
    YEAR(rfi.dispatch_date_time) AS Year,
    COUNT(*) AS IncidentCount
FROM dbo.RaleighFireIncidents rfi
GROUP BY
    YEAR(rfi.dispatch_date_time)
ORDER BY
    Year DESC;
GO
