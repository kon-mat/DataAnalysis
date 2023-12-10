-- suppress row numbers
SET NOCOUNT ON

-- show the first 2 events
SELECT TOP 2
	e.EventName AS 'What',
	e.EventDate AS 'When'
FROM
	WorldEvents.dbo.tblEvent AS e
ORDER BY
	e.EventDate ASC

-- now repeat for the last 2
SELECT TOP 2
	e.EventName AS 'What',
	e.EventDate AS 'When'
FROM
	WorldEvents.dbo.tblEvent AS e
ORDER BY
	e.EventDate DESC
