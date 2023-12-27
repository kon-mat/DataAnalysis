SELECT TOP 3
	e.EventName,
	e.EventDate
FROM
	WorldEvents.dbo.tblEvent AS e
WHERE
	e.EventName LIKE '%Teletubbies%'
	OR e.EventName LIKE '%Pandy%';