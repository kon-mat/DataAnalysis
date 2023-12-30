USE WorldEvents


SELECT
	ctr.CountryID,
	ctr.CountryName,
	e.EventID

FROM
	dbo.tblCountry ctr

FULL OUTER JOIN
	dbo.tblEvent e
	ON
		ctr.CountryID = e.CountryID

WHERE
	e.EventID IS NULL