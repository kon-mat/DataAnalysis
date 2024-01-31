USE WorldEvents
GO


WITH First_Half_CTE as (
	SELECT
		e.EventName
		, e.CategoryID
	FROM
		tblEvent e
	WHERE
		e.EventName like '[A-M]%'
)

SELECT
	c.CategoryName
	, f.EventName
FROM
	First_Half_CTE f
	INNER JOIN tblCategory c on f.CategoryID = c.CategoryID