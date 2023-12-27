
SELECT
	e.EventName,
	LEN(e.EventName) AS 'Length of name'
FROM
	WorldEvents.dbo.tblEvent e
ORDER BY
	'Length of name'