USE WorldEvents
GO



SELECT
	e.EventName,
	e.EventDetails
FROM
	tblEvent e
WHERE
	-- ... the country for the event isn't in the last 30 in alphabetical order and ...
	e.CountryID NOT IN (
		SELECT
			TOP(30) c.CountryID
		FROM
			tblCountry c
		ORDER BY
			c.CountryName DESC
	)

	-- the category isn't in the last 15 in alphabetical order
	AND e.CategoryID NOT IN (
		SELECT
			TOP(15) c.CategoryID
		FROM
			tblCategory c
		ORDER BY
			c.CategoryName DESC
	)

ORDER BY
	e.EventDate