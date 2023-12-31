USE WorldEvents



SELECT
	-- get the first letter of the category name, and show in upper case
	UPPER(LEFT(c.CategoryName, 1)) AS [Category initial],

	-- count how many events there are
	COUNT(*) AS [Number of events],

	-- from the inside out: get the length of each event's name , turn it into a decimal number, average it and the
	-- present the result formatted to 2 decimal places

	FORMAT(
		AVG(
			CAST(
				LEN(e.EventName) AS float)
			)
		, '0.00'
	) AS [Average event name length]

FROM
	dbo.tblCategory c

	INNER JOIN dbo.tblEvent e
		ON c.CategoryID = e.CategoryID

GROUP BY
	-- need to group by the first letter of the category too
	UPPER(LEFT(c.CategoryName, 1))

ORDER BY
	[Category initial]