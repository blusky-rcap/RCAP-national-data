

DECLARE
   @BeginDate date,
   @EndDate date,
   @ReportingRegion varchar(12);

SET @BeginDate = '4/1/2022';
SET @EndDate = '6/30/2022';
SET @ReportingRegion = 'CU';

WITH LatestReportFromActiveProject (Source, ReportDate, ItemId, ProjectId)
AS
    (
        SELECT DISTINCT
            'Report',
            r.PeriodEnd,
            r.Id,
            activeDuring.Id
        FROM dbo.Report r
        JOIN dbo.Report_X_Project rxp ON rxp.ReportId = r.Id
        JOIN dbo.ufnProjectsActiveDuring(@BeginDate, @EndDate) activeDuring ON activeDuring.Id = rxp.ProjectId
    UNION 
        SELECT DISTINCT
            'Activity',
            pta.[Date],
            pta.Id,
            pta.ProjectID
        FROM dbo.ProjectTaskActivity pta
        JOIN dbo.ufnProjectsActiveDuring(@BeginDate, @EndDate) activeDuring ON activeDuring.Id = pta.ProjectId
            AND (pta.[Date] BETWEEN @BeginDate AND @EndDate) AND (pta.Activity LIKE '%Summary%')
            
    )




SELECT DISTINCT
    dbo.ufnGetRegNameFromUSPSCODE (proj.[State]) AS "Region",
    proj.[State] AS "State",
    CONCAT(c.FirstName, ' ', c.LastName) AS "TAP",
    c.Email AS "TAP Email",
    proj.[Name] AS "Project",
    f.[Name] AS "Funding Program",

    CASE
        WHEN rfap.ReportDate IS NULL THEN 'Missing'
        ELSE FORMAT(rfap.ReportDate, 'd')
    END AS "Last Report"
FROM dbo.ufnProjectsActiveDuring(@BeginDate, @EndDate) allActive
LEFT JOIN  LatestReportFromActiveProject rfap ON rfap.ProjectId = allActive.Id
JOIN dbo.Project proj ON proj.Id = allActive.Id
JOIN dbo.Funding f ON f.Id = proj.FundingProgId
JOIN dbo.UserDetail ud ON ud.UserId = proj.ProjectOwner JOIN dbo.Contact c ON c.Id = ud.ContactId
-- WHERE rfap.ProjectId IS NULL