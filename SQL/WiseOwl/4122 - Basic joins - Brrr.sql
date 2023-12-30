USE WorldEvents


SELECT
	e.EventName,
	e.EventDate,
	ctr.CountryName,
	cnt.ContinentName

FROM
	dbo.tblEvent e

INNER JOIN
	dbo.tblCountry ctr
	ON
		e.CountryID = ctr.CountryID

INNER JOIN
	dbo.tblContinent cnt
	ON
		ctr.ContinentID = cnt.ContinentID

WHERE
	cnt.ContinentName LIKE 'Antarctic'
	OR ctr.CountryName LIKE 'Russia'