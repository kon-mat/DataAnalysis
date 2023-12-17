
SELECT
	c.CountryName,
	CASE
		WHEN c.ContinentID IN(1, 3) THEN
			'Eurasia'
		WHEN c.ContinentID IN(5, 6) THEN
			'Americas'
		WHEN c.ContinentID IN(2, 4) THEN
			'Somewhere hot'
		WHEN c.ContinentID = 7 THEN
			'Somewhere hot'
		ELSE
			'Somewhere else'
	END AS CountryLocation
FROM
	WorldEvents.dbo.tblCountry c