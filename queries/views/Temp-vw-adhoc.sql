GO

CREATE OR ALTER VIEW dbo.vw_more_expanded_adhoc AS

WITH
    FirstPlaceIdOfProject (ProjectId, FirstPlaceIdId, PlaceIdCount)
    AS
    (
        SELECT
        p.Id, MIN(pxpi.ZipPlaceIdId), COUNT(pxpi.ZipPlaceIdId) 
        FROM dbo.Project p
        JOIN dbo.Project_X_ZipPlaceId pxpi ON p.Id = pxpi.ProjectId
        GROUP BY p.Id
    ),
    PlaceAndZipCodeCountForProject (ProjectId, PlaceIdCount, ZipCodeCount)
    AS
    (
        SELECT
            pxzp.ProjectId,
            COUNT(DISTINCT zpi.PlaceID),
            COUNT(DISTINCT zpi.ZIP)
        FROM dbo.Project_X_ZipPlaceId pxzp
        JOIN dbo.ZipPlaceId zpi ON zpi.PlaceID = pxzp.ZipPlaceIdId
        GROUP BY pxzp.ProjectId
    ),
    ProjectLeverage(ProjectId, LeverageApplications, TotalLeverageSought, LeverageReceipts, TotalLeverageReceived)
    AS
    (
        SELECT
            p.Id AS "ProjectId",
            COUNT(lf.Id) AS "LeverageApplications",
            SUM(lf.AppliedAmount) AS "TotalLeverageSought",
            COUNT(lr.Id) AS "LeverageReceipts",
            SUM(lr.Amount) AS "TotalLeverageReceived"
        FROM dbo.Project p
        LEFT JOIN dbo.LeverageFunds lf ON lf.ProjectId = p.Id
        LEFT JOIN dbo.Receipt lr ON lr.LeverageId = lf.Id
        GROUP BY p.Id
    ),
    FundingHistory (ProjectId, History)
    AS
    (
        SELECT
            p.Id AS "ProjectId",
            STRING_AGG(CONCAT(pfh.Funding, '(', pfh.sDate, '-', pfh.eDate, ')'), '; ') AS "History"
        FROM dbo.Project p
        JOIN dbo.ProjectFundingHistory pfh ON pfh.ProjectId = p.Id
        GROUP BY p.Id
    ),
    CompletedTasks (ProjectId, TasksCompleted, Tasks)
    AS
    (
        SELECT
            p.Id,
            COUNT(pxt.Id),
            STRING_AGG(CONCAT(tt.Task,'(', tt.TaskCode, ') ', FORMAT(pxt.EndDate, 'd')), '; ')
        FROM dbo.Project p
        JOIN dbo.Project_X_Task pxt ON pxt.ProjectId = p.Id AND pxt.TaskStatus LIKE 'Completed'
        JOIN dbo.TaskType tt ON tt.Id = pxt.TaskTypeId
        GROUP BY p.Id
    )

SELECT
    p.[State] AS "Project State",
    p.PrimaryCounty AS "Project County",
    p.OwnerFullname AS "TAP Name",
    c.Email AS "Tap Email",
    dbo.ufnGetRegionsAsStringFromUSPSCode(p.[State]) AS "Region",
    FORMAT(p.CreatedDateTime, 'd') AS "Project Created",
    FORMAT(p.ModifiedDateTime, 'd') AS "Project Modified",
    p.ZipCodes AS "All Zipcodes",
    LEFT(p.ZipCodes, CHARINDEX(',', p.ZipCodes)) AS "First Zip Code",
    zpid.CountyName AS "1st County",
    zpid.PlaceName AS "1st Placename",
    s.USPSCode AS "1st State",
    zpid.Lat AS "1st Lat",
    zpid.Long AS "First Long",
    p.PlaceIds AS "Place IDs",
    p.[Name] AS "Project",
    FORMAT(p.StartDate, 'd') AS "Started",
    FORMAT(p.EndDate, 'd') AS "Ended",
    p.[Status] AS "Project Status",
    f.[Name] AS "Funding Program",
    fh.History AS "Funding History",
    ct.Tasks AS "Tasks",
    ct.TasksCompleted AS "TasksCompleted",
    p.Referral AS "Referral",
    p.CongressionalDist AS "Congressional District",
    it.InfraType AS "Infrastructure Type",
    dbo.ufnGetOutcomeAsStringFromProjectId(p.Id) AS "Outcomes",
    dbo.ufnGetAssistanceTypesAsStringFromProjectId(p.Id) AS "Assistance Types",
    CASE
        WHEN p.Tribal = 1 THEN 'Yes'
        ELSE 'No'
    END AS "Tribal",
    p.TribalType AS "Tribal Type",
    p.TribalPop AS "Tribal Population",
    p.PopServed AS "Population Served",
    p.LowIncomePop AS "Low Income Population",
    p.MinorityPop AS "Minority Population",
    p.HouseHolds AS "Number of Households",
    p.PersonsPHouseHold AS "Persons per Household",
    p.MedianIncome AS "Median Income",
    p.ParameterBefore AS "Connections Before",
    p.ParameterAfter AS "Connections After",
    p.ConstructionStatus AS "Construction Status",
    pl.*
FROM dbo.Project p
JOIN dbo.Funding f ON p.FundingProgId = f.Id
JOIN dbo.InfraType it ON it.Id = p.InfraType
JOIN FirstPlaceIdOfProject fpid ON fpid.ProjectId = p.Id
LEFT JOIN PlaceAndZipCodeCountForProject pzfp ON pzfp.ProjectId = p.Id
LEFT JOIN dbo.ZipPlaceId zpid ON zpid.Id = fpid.FirstPlaceIdId
JOIN FundingHistory fh ON fh.ProjectId = p.Id
JOIN CompletedTasks ct ON ct.ProjectId = p.Id
JOIN dbo.[State] s ON s.Id = zpid.StateID
LEFT JOIN ProjectLeverage pl ON pl.ProjectId = p.Id
JOIN dbo.UserDetail ud ON ud.UserId = p.ProjectOwner
JOIN dbo.Contact c ON c.Id = ud.ContactId