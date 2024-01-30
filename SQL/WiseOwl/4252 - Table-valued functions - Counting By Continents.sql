USE WorldEvents
GO


ALTER FUNCTION fnContinentSummary (
	@Continent varchar(100)
	, @MonthName varchar(100)
)
RETURNS TABLE 
AS

RETURN

	-- show events happening in this continent and month
	SELECT
		cnt.ContinentName
		, count(distinct e.EventID) as [Number of events]
		, count(distinct ctr.CountryID) as [Number of countries]
		, count(distinct e.CategoryID) as [Number of categories]
	FROM
		tblEvent e
		INNER JOIN tblCountry ctr on e.CountryID = ctr.CountryID
		INNER JOIN tblContinent cnt on ctr.ContinentID = cnt.ContinentID
	WHERE
		cnt.ContinentName = @Continent

		-- FORMAT available from version 2012 of SQL Server
		and FORMAT(e.EventDate,'MMMM') = @MonthName
	GROUP BY
		cnt.ContinentName

GO


-- test this out
SELECT * FROM dbo.fnContinentSummary('Europe','April')

