USE WorldEvents
GO


ALTER FUNCTION fnEventsForYear (
	@year int
)
RETURNS TABLE
AS

RETURN
	SELECT
		e.EventName
		, cat.CategoryName
		, ctr.CountryName
	FROM
		tblEvent e
		INNER JOIN tblCategory cat on e.CategoryID = cat.CategoryID
		INNER JOIN tblCountry ctr on e.CountryID = ctr.CountryID
	WHERE
		YEAR(e.EventDate) = @year
GO


SELECT
	*
FROM
	dbo.fnEventsForYear(1918) AS e