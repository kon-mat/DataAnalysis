USE WorldEvents
GO


ALTER PROC spCategoryEvents (
	@CategoryName varchar(100) = NULL,
	@After DATETIME = NULL,
	@CategoryID INT = NULL
)
AS

SELECT
	cat.CategoryName,
	e.EventDate,
	e.CategoryID
FROM
	tblEvent e

	INNER JOIN tblCategory cat
		ON e.CategoryID = cat.CategoryID

WHERE
	(@CategoryName IS NULL
	OR cat.CategoryName LIKE '%' + @CategoryName + '%')
	AND
	(@After IS NULL
	OR e.EventDate >= @After)
	AND
	(@CategoryID IS NULL
	OR e.CategoryID = @CategoryID)
ORDER BY
	e.EventDate

GO


-- there should be 14 events since 1990 about death
EXEC spCategoryEvents 
	@CategoryName = 'death', 
	@After = '19900101'
GO

-- category 16 is "Royalty", which has 16 events
EXEC spCategoryEvents 
	@CategoryId = 16
GO