USE WorldEvents



SELECT
	cnt.ContinentName,
	ctr.CountryName,
	COUNT(*) AS [Number of events]
FROM
	dbo.tblEvent e

	INNER JOIN dbo.tblCountry ctr
		ON e.CountryID = ctr.CountryID

	INNER JOIN dbo.tblContinent cnt
		ON ctr.ContinentID = cnt.ContinentID

WHERE
	cnt.ContinentName != 'Europe'

GROUP BY
	cnt.ContinentName,
	ctr.CountryName

HAVING
	COUNT(*) >= 5