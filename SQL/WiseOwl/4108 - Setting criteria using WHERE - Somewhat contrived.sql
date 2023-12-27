SELECT
	*
FROM
	WorldEvents.dbo.tblEvent AS e
WHERE
	(
		e.CountryID IN (8, 22, 30, 35)

		OR e.EventDetails LIKE ('% water')
		OR e.EventDetails LIKE ('% water %')
		OR e.EventDetails LIKE ('water %')

		OR e.CategoryID = 4
	)
	AND e.EventDate >= '19700101';