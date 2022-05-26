DECLARE
    @RegionReporting varchar(12);

SET @RegionReporting = 'SERCAP';

SELECT
    *
    
FROM dbo.vw_more_expanded_adhoc ea 

JOIN dbo.ufnProjectsActiveDuring('10/1/2021', '4/30/2022') pad ON pad.Id = ea.ProjectId
-- WHERE ea.[Region] LIKE 'KY' -- AND ea.[Funding History] LIKE '%NPA 1%'

WHERE
        (ea.Region LIKE @RegionReporting OR @RegionReporting IS NULL)