SELECT
	*
FROM
	WorldEvents.dbo.tblEvent AS e
WHERE
	e.CategoryID != 14
	AND e.EventDetails LIKE '%Train%';


SELECT
	*
FROM
	WorldEvents.dbo.tblEvent AS e
WHERE
	e.CountryID = 13
	AND e.EventName NOT LIKE '%Space%'
	AND e.EventDetails NOT LIKE '%Space%';


SELECT
	*
FROM
	WorldEvents.dbo.tblEvent AS e
WHERE
	e.CategoryID IN (5, 6)
	AND e.EventDetails NOT LIKE '%War%'
	AND e.EventDetails NOT LIKE '%Death%';
	
