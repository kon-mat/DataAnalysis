USE WorldEvents

SELECT
	e.EventName,
	e.EventDate,
	c.CategoryName
FROM
	dbo.tblEvent e
INNER JOIN
	dbo.tblCategory c
	ON
		e.CategoryID = c.CategoryID
ORDER BY
	e.EventDate DESC


SELECT
	e.EventName,
	e.EventDate,
	c.CategoryName
FROM
	dbo.tblEvent e
FULL OUTER JOIN
	dbo.tblCategory c
	ON
		e.CategoryID = c.CategoryID
WHERE
	e.EventName IS NULL
ORDER BY
	e.EventDate DESC