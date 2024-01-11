USE WorldEvents
GO


DECLARE @YearOfBirth INT = 1990

SELECT
	e.EventName,
	e.EventDate,
	c.CountryName
FROM
	tblEvent e

	INNER JOIN tblCountry c
		ON e.CategoryID = c.CountryID
WHERE
	e.EventDate BETWEEN DATEFROMPARTS(@YearOfBirth, 1, 1) 
		AND DATEFROMPARTS(@YearOfBirth, 12, 31)