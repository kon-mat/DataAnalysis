
SELECT
	e.EventName + 
		' (category ' + 
		e.CategoryID + 
		')' AS 'Event (category)',

	e.EventDate
FROM
	WorldEvents.dbo.tblEvent e
WHERE
	e.CountryID = 1