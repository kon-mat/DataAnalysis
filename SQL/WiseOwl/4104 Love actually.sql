SELECT TOP 3
	e.EventName,
	e.EventDate
FROM
	WorldEvents.dbo.tblEvent AS e
WHERE
	e.CategoryID = 11;