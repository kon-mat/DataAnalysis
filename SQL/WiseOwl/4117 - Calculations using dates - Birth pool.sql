
SELECT
	e.EventName,
	FORMAT(e.EventDate,'dd MMM yyyy') AS 'Event date',

	-- difference in days
	DateDiff(day,e.EventDate,'19640304') AS 'Days offset',

	-- number of days from birthday
	ABS(
		DateDiff(day,e.EventDate,'19640304')
	) AS 'Days difference'
FROM
	tblEvent AS e
ORDER BY
	-- show closest events first
	'Days difference' ASC