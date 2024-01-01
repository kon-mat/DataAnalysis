USE WorldEvents
GO



ALTER VIEW vwEverything 
AS

SELECT
	c.CategoryName AS Category,
	cnt.ContinentName AS Continent,
	ctr.CountryName AS Country,
	e.EventName,
	e.EventDate

FROM
	tblEvent e

	INNER JOIN tblCategory c
		ON e.CategoryID = c.CategoryID

	INNER JOIN tblCountry ctr
		ON e.CountryID = ctr.CountryID

	INNER JOIN tblContinent cnt
		ON ctr.ContinentID = cnt.ContinentID

