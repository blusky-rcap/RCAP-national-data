
-- Report tasks based on Region, Status, Funder, and Status Date
--
-- Parameters:
-- @PeriodStart is the beginning date for the period on which to report completions; if NULL, report from the beginning of the DCS record
-- @PeriodEnd is the ending dates for the period on which to report completions; if NULL, report through the most recent date in the database
-- @RegionReporting is a single region for which to report tasks, if NULL report includes all regions
-- @FundingProgram is the name of a specific HHS/OCS Program for which to report; if NULL, report all HHS/OCS

USE dcs
GO

DECLARE
    @PeriodStart date,
    @PeriodEnd date,
    @RegionReporting varchar(12),
    @ReportTaskStatus varchar(32),
    @ReportFundingProgram varchar(128);

SET @PeriodStart = '10/1/2021';
SET @PeriodEnd = '4/30/2022';
SET @RegionReporting = 'GLRCAP' -- 'MAP';
SET @ReportTaskStatus = 'Completed';
SET @ReportFundingProgram = NULL;

SELECT DISTINCT
    ts.Region AS "Region",
    ts.[State] AS "State",
    CONCAT(ts.TapFirstName, ' ', ts.TapLastName, ' (', ts.TapEmail, ')') AS "TAP",
    ts.Funding AS "Funding Program",
    ts.Project AS "Project",
    ts.ProjectStatus AS "Project Status",
    ts.Task AS "Task",
    ts.TaskStatus AS "Task Status",
    ts.DateTaskCompleted AS "Task Completion Date",
    ts.DateTaskModified AS "Task Modification Date"
FROM dbo.vw_TaskStatus ts
WHERE
        (ts.Region LIKE @RegionReporting OR @RegionReporting IS NULL)
    AND
        (
            (@PeriodStart IS NULL AND @PeriodEnd IS NULL)
        OR
            (ts.DateTaskCompleted BETWEEN @PeriodStart AND @PeriodEnd)
        )
    AND
        (@ReportTaskStatus IS NULL OR ts.TaskStatus LIKE @ReportTaskStatus)
    AND
        (@ReportFundingProgram IS NULL OR ts.Funding LIKE @ReportFundingProgram)