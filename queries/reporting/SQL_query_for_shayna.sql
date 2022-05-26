
DECLARE
    @PeriodStart date,
    @PeriodEnd date

SET @PeriodStart = '2/1/2022';
SET @PeriodEnd = '4/30/2022';

SELECT * FROM dbo.Contact

WHERE State in ('IA', 'KS', 'MN', 'MO', 'MT' ,'NE','ND', 'SD', 'WY') 
AND CreatedDateTime BETWEEN '1/1/2019' AND '5/18/2022'
Order by LastName