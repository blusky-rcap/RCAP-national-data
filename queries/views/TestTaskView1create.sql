-- Retrieve Tasks Completed With Project and Funding
--

USE dcs;
GO

CREATE OR ALTER VIEW dbo.vw_TestTaskView
AS

SELECT
    p.Id AS "ProjectId",
    p.[Name] AS Project,
    pfh.[Funding] AS Funding,
    FORMAT(pfh.sDate, 'd') AS FundingStartDate,
    FORMAT(pfh.sDate, 'd') AS TaskCompletionDate,
    FORMAT(pfh.eDate, 'd') AS FundingEndingDate,
    pxt.TaskTypeId AS TasktType,
    pxt.TaskStatus,
    tt.Task AS "Task",
    tt.TaskCode AS "TaskCode"
    
FROM dbo.Project p
JOIN dbo.ProjectFundingHistory pfh ON p.Id = pfh.ProjectId
JOIN dbo.Project_X_Task pxt ON pxt.ProjectId = p.Id AND pxt.EndDate BETWEEN pfh.sDate AND pfh.eDate
JOIN dbo.TaskType tt ON tt.Id = pxt.TaskTypeId
