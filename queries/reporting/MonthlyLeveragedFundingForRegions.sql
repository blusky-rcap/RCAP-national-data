--This report highlights the flow from Task to Award
--The hypothesis is that there is a funnel that can be analyzed to understand program effectiveness
--

USE dcs;

DECLARE
   @BeginDate date,
   @EndDate date,
   @ReportingRegion varchar(12);

SET @BeginDate = '10/1/2021';
SET @EndDate = '5/31/2022';
SET @ReportingRegion =  'SERCAP';

SELECT
    reg.Name AS "Region",
    s.Name AS "State",
    f."Name" AS "Funding Program",
    CONCAT(p.[Name], ' (', p.Id, ')') AS "Project (Id)",
    l.Id AS "Leverage Id",
    pxt.StartDate AS "Start of Application Task",
    pxt.[TaskStatus] AS "Status of Application Task",
    pxt.EndDate AS "End of Application Task",
    l.Source AS 'Leveraged Funding Source',
    CAST(l.AppliedAmount AS decimal) AS "Amount Requested",
    l.AppliedType AS 'Application Type', format(l.AppDate,'d') AS 'Application Date',
    CASE
        WHEN l.Denied IS NULL THEN 'Null'
        WHEN l.Denied = 0 THEN 'FALSE'
        WHEN l.Denied = 1 THEN 'TRUE'
        ELSE 'Error'
    END AS "Denial",
    CAST(r.Amount AS decimal) AS "Amount Received",
    r.Type AS 'Type', format(r.ReceiptDate,'d') AS 'Date Received',
    CASE
         WHEN r.ReceiptDate < l.AppDate AND r.ReceiptDate NOT BETWEEN @BeginDate AND @EndDate THEN 'Skip and Check Dates'
         WHEN r.ReceiptDate > @EndDate THEN 'Received after end'
         WHEN r.ReceiptDate < l.AppDate AND r.ReceiptDate BETWEEN @BeginDate AND @EndDate THEN 'Check Dates'
         ELSE 'None'
    END AS "Anomaly",
    CASE
        WHEN r.ReceiptDate IS NULL THEN 'N'
        WHEN r.ReceiptDate  NOT BETWEEN @BeginDate AND @EndDate THEN 'N'
        ELSE 'Y'
    END AS "Receipt in range" 
FROM dbo.Project p
    JOIN dbo.Funding f ON p.FundingProgId=f.Id
    LEFT JOIN dbo.Project_X_Task pxt ON pxt.ProjectId=p.Id AND pxt.TaskTypeId=3 
    JOIN dbo.State s ON p.State = s.USPSCode
    JOIN dbo.Region_X_State rxs ON s.Id=rxs.StateId
    JOIN dbo.Region reg ON rxs.RegionId=reg.Id
    LEFT JOIN dbo.LeverageFunds l ON l.ProjectId=p.Id
    LEFT JOIN dbo.Receipt r ON l.Id=r.LeverageId 
    WHERE ((ReceiptDate BETWEEN @BeginDate AND @EndDate) OR (l.AppDate BETWEEN @BeginDate AND @EndDate))
    AND (reg.Name LIKE @ReportingRegion OR @ReportingRegion IS NULL)
ORDER BY reg.Name, s.Name, p.Name, l.AppDate DESC;