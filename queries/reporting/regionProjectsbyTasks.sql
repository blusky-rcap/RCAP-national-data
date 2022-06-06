--TaskCode
-- ('T002', 'T003', 'T005', 'T007', 'T008', 'T011', 'T012', 'T019', 'T021', 'T029', 'T031', 'T040', 'T041', 'T045', 'T046', 'T048', 'T051', 'T052', 'T053', 'T054', 'T062', 'T073', 'T078', 'T080', 'T081', 'T087', 'T089', 'CF01', 'CF02', 'Eco-0'2, 'Eco-04', 'Eco-04', 'G001', 'G001')


USE dcs;

DECLARE
   @BeginDate date,
   @EndDate date,
   @ReportingRegion varchar(12);

SET @BeginDate = '10/1/2020';
SET @EndDate = '4/30/2022';
SET @ReportingRegion = 'MAP';

SELECT
    p.Name AS "Project",
    p.[State] AS "State",
    OwnerFullname AS "TAP",
    FORMAT(p.StartDate, 'd') AS "Start date",
    p.[Status] AS "Project Status",
    FORMAT(p.EndDate, 'd') AS "End date",
    f.[Name] AS "Funding",
    reg.Name AS "Region",
    tt.TaskCode AS "Task Code",
    pxt.TaskStatus AS "Task Status",
    p.PopServed AS "Population Served",
    p.Tribal AS "Tribal",
    p.TribalType AS "TribalType",
    p.TribalPop AS "Tribal Population",
    p.LowIncomePop AS "Low Income Population",
    p.MinorityPop AS "Minority Population",
    p.PersonsPHouseHold AS "Persons per Household",
    p.MedianIncome AS "MedianIncome",
    p.ZipCodes AS "Zip Codes",
    p.CongressionalDist AS "Congressional District",
    p.State AS "State",
    p.PrimaryCounty AS "Primary County",
    p.PlacesServed AS "Places Served"
    
FROM dbo.Project p
JOIN dbo.Project_X_Task pxt ON pxt.ProjectId = p.Id 
JOIN dbo.TaskType tt ON pxt.TaskTypeId = tt.Id
JOIN dbo.Funding f ON p.FundingProgId = f.Id
JOIN dbo.State s ON p.State = s.USPSCode
JOIN dbo.Region_X_State rxs ON s.Id=rxs.StateId
JOIN dbo.Region reg ON rxs.RegionId=reg.Id
WHERE (reg.Name LIKE @ReportingRegion OR @ReportingRegion IS NULL)
AND NOT pxt.TaskStatus = 'Invalid' AND NOT pxt.TaskStatus = 'Cancelled'
AND tt.TaskCode in ('T002', 'T003', 'T005', 'T007', 'T008', 'T011', 'T012', 'T019', 'T021', 'T029', 'T031', 'T040', 'T041', 'T045', 'T046', 'T048', 'T051', 'T052', 'T053', 'T054', 'T062', 'T073', 'T078', 'T080', 'T081', 'T087', 'T089', 'CF01', 'CF02', 'Eco-02', 'Eco-04', 'Eco-04', 'G001', 'G001')

ORDER BY p.[Status], p.EndDate