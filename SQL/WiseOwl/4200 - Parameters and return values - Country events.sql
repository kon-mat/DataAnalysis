USE WorldEvents
GO


ALTER PROC spCountryEvents (
	@Country VARCHAR(100)
)
AS

--Select information about all countries
SELECT
	e.EventName,
	e.EventDate,
	c.CountryName
FROM
	tblEvent e

	INNER JOIN tblCountry c
		ON e.CountryID = c.CountryID

WHERE
	c.CountryName LIKE '%' + @Country + '%'
GO


spCountryEvents 'Ukraine'