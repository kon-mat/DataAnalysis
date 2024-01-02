USE WorldEvents
GO


SELECT
	e.EventName
FROM
	tblEvent e
WHERE
	LEN(e.EventName) > (
	SELECT
		AVG(LEN(ev.EventName))
	FROM
		tblEvent ev
)