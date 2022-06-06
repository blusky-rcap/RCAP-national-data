--Find all of the projects with Management Capacity Tasks Completed under a specificed funding program during a particular time period
--Each line of the result set is one project, and the task count identifies the number of qualified tasks for the project, making it easy to count projects or tasks.

-- Management Capacity is supported by the following task codes: ('T011', 'T021', 'T087', 'T089', 'T024', 'T026', 'T027', 'T028', 'T034', 'T039', 'T045', 'T054', 'T071', 'T072', 'T078', 'T079', 'T080', 'T086')

DECLARE @ReportStart date, @ReportEnd date, @ReportRegion varchar(8), @ReportFunding varchar(255);
SET @ReportStart = NULL;
SET @ReportEnd = NULL;
SET @ReportRegion = NULL;
SET @ReportFunding = 'EPA NPA 2 Drinking Water 20-22';

WITH CompletedForProject(ProjectId, TaskCodes, TaskCount)
AS
(
    SELECT
        cuf.ProjectId,
        STRING_AGG(CONCAT(cuf.TaskCode, ' (', cuf.TaskCompletionDate, ')'), ', '),
        COUNT(cuf.TaskCode)
    FROM dbo.vw_CompletedUnderFunding cuf
    WHERE cuf.Funding LIKE @ReportFunding AND cuf.TaskCode in ('T011', 'T021', 'T087', 'T089', 'T024', 'T026', 'T027', 'T028', 'T034', 'T039', 'T045', 'T054', 'T071', 'T072', 'T078', 'T079', 'T080', 'T086')
    GROUP BY cuf.ProjectId
)

SELECT DISTINCT
    vcuf.Project AS "Project",
    cfp.TaskCount AS "Tasks completed",
    cfp.TaskCodes AS "Task codes (dates completed)"
FROM CompletedForProject cfp
JOIN dbo.vw_CompletedUnderFunding vcuf ON vcuf.ProjectId = cfp.ProjectId