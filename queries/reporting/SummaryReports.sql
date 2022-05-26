-- This query returns all Quarterly or Final Project Summaries for the specified time period and region
-- It queries the new Status Report and the legacy Activity reports

DECLARE
   @BeginDate date,
   @EndDate date,
   @DefaultModificationDate date,
   @ReportingRegion varchar(12);

SET @BeginDate = '2/1/2022';
SET @EndDate = '4/30/2022';
SET @DefaultModificationDate = '11/20/2021'; -- For reasons unclear to mortal humans, don't ever accept a modification date before 11/20/2021, at least for Activity-based reports
SET @ReportingRegion = 'SERCAP'; 

SELECT DISTINCT
    'Status Report' AS "Source",
    FORMAT(r.CreatedDateTime, 'd') AS "Date Submitted",
    FORMAT(r.ModifiedDateTime, 'd') AS "Date Modified",
    proj.[State] AS "State",
    reg.Name AS "Region",
    proj.[Name] AS "Project",
    f.[Name] AS "Funding Program",
    rt.[Name] AS "Report Type",
    CONCAT(c.FirstName, ' ', c.LastName) AS "Submitter",
    FORMAT(r.PeriodEnd, 'd') AS "Effective Date",
    rp.Value AS "Delivery Method",
    rn.Value AS "Community Members Engaged",
    r.Narrative AS "Report Narrative"
FROM dbo.Report r
JOIN dbo.Report_X_Project rxp ON rxp.ReportId = r.Id AND ((r.PeriodEnd BETWEEN @BeginDate AND @EndDate) OR (r.CreatedDateTime BETWEEN @BeginDate AND @EndDate) OR (r.ModifiedDateTime BETWEEN @BeginDate AND @EndDate))
JOIN dbo.Project proj ON proj.Id = rxp.ProjectId
JOIN dbo.Funding f ON f.Id = proj.FundingProgId
JOIN dbo.[State] s ON s.USPSCode = proj.[State]
JOIN dbo.Region_X_State rxs ON rxs.StateId = s.Id
JOIN dbo.Region reg ON reg.Id = rxs.RegionId AND ((reg.Name LIKE @ReportingRegion) OR (@ReportingRegion IS NULL))
JOIN dbo.ReportType rt ON r.ReportTypeId = rt.Id
JOIN dbo.UserDetail ud ON ud.UserId = r.ReporterUserId
JOIN dbo.Contact c ON c.Id = ud.ContactId
JOIN dbo.Report_X_Attribute rp ON rp.ReportId = r.Id
JOIN dbo.ReportAttribute p ON p.Id = rp.AttrId AND p.Id = 1
JOIN dbo.Report_X_Attribute rn ON rn.ReportId = r.Id
JOIN dbo.ReportAttribute n ON n.Id = rn.AttrId AND n.Id = 2

UNION

SELECT DISTINCT
    'Activity' AS "Source",
    FORMAT(pta.CreatedDateTime, 'd') AS "Date Submitted",
    FORMAT(pta.ModifiedDateTime, 'd') AS "Date Modified",
    proj.[State] AS "State",
    reg.Name AS "Region",
    proj.[Name] AS "Project",
    f.[Name] AS "Funding Program",
    pta.Activity AS "Report Type",
    '' AS "Submitter",
    FORMAT(pta.Date, 'd') AS "Effective Date",
    NULL AS "Delivery Method",
    NULL AS "Community Members Engaged",
    pta.[Desc] AS "Report Narrative"
FROM dbo.Project proj
JOIN dbo.Funding f ON f.Id = proj.FundingProgId
JOIN dbo.[State] s ON s.USPSCode = proj.[State]
JOIN dbo.Region_X_State rxs ON rxs.StateId = s.Id
JOIN dbo.Region reg ON reg.Id = rxs.RegionId AND ((reg.Name LIKE @ReportingRegion) OR (@ReportingRegion IS NULL))
JOIN dbo.ProjectTaskActivity pta ON pta.ProjectID = proj.Id  AND
        ((pta.Date BETWEEN @BeginDate AND @EndDate)
            OR (pta.CreatedDateTime BETWEEN @BeginDate AND @EndDate) 
            OR (pta.ModifiedDateTime BETWEEN @BeginDate AND @EndDate) AND (pta.ModifiedDateTime BETWEEN @DefaultModificationDate AND @EndDate)) -- see note in declarations above)
        AND (pta.Activity LIKE '%Summary%')
-- JOIN dbo.UserDetail ud ON ud.UserId = r.ReporterUserId
-- JOIN dbo.Contact c ON c.Id = ud.ContactId
