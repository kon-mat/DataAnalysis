USE WorldEvents



SELECT
	c.CategoryName,
	COUNT(*) AS [Number of events]
FROM
	dbo.tblEvent e

	INNER JOIN dbo.tblCategory c
		ON e.CategoryID = c.CategoryID

GROUP BY
	c.CategoryName
ORDER BY
	[Number of events] DESC