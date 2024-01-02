USE WorldEvents
GO


SELECT
	e.EventName,
	e.EventDate,
	c.CountryName
FROM
	tblEvent e

	INNER JOIN tblCountry c
		ON e.CategoryID = c.CountryID

WHERE
	e.EventDate > (
	SELECT
		MAX(ev.EventDate)
	FROM
		tblEvent ev
	WHERE
		ev.CountryID = 21
)

ORDER BY
	e.EventDate DESC
