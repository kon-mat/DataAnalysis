SELECT
	e.EventName AS 'What',
	e.EventDate AS 'When'
FROM
	WorldEvents.dbo.tblEvent AS e
WHERE
	e.EventDate between '20050201' and '20050228';