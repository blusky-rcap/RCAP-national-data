-- Find all the applied tags for a region

-- Note: this view does not have a date applied column because that information is unknowable. Bummer. I left some code in against the day when our eyes are opened to the splendor -- jf
DECLARE
    @PeriodStart date,
    @PeriodEnd date,
    @RegionReporting varchar(12);

SET @PeriodStart = '2/1/2022';
SET @PeriodEnd = '4/30/2022';
SET @RegionReporting = 'SERCAP';

SELECT DISTINCT * FROM dbo.vw_AppliedTags at
WHERE
    (at.Region LIKE @RegionReporting OR @RegionReporting IS NULL)
-- AND
--     (at.[Date Tagged] > @PeriodStart OR @PeriodStart IS NULL)
-- AND
--     (at.[Date Tagged] < @PeriodEnd OR @PeriodEnd IS NULL)
