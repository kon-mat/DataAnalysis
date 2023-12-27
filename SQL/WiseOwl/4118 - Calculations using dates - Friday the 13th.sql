
SELECT
	e.EventName,

	-- the date
	FORMAT(e.EventDate,'dddd dd MMMM, yyyy') AS 'When',

	-- the day of the week
	DateName(weekday,e.EventDate) AS 'Day of week',

	-- the day number
	day(e.EventDate) AS 'Day number'
FROM
	tblEvent AS e
WHERE
	-- limit to Friday 13th
	DateName(weekday,e.EventDate) = 'Friday' and
	day(e.EventDate) = 13