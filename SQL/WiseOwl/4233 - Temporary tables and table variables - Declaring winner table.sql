USE WorldEvents
GO


DECLARE @WinnerTable TABLE (
	Source varchar(100)
	, Winner varchar(100)
	, [Number of events] int
)


-- top events category 
INSERT INTO @WinnerTable (
	Source
	, Winner
	, [Number of events]
)
SELECT TOP 1
	'Category'
	, cat.CategoryName
	, COUNT(*)
FROM
	tblEvent e
	INNER JOIN tblCategory cat on e.CategoryID = cat.CategoryID
GROUP BY
	cat.CategoryName
ORDER BY
	COUNT(*) DESC	


-- top events country
INSERT INTO @WinnerTable (
	Source
	, Winner
	, [Number of events]
)
SELECT TOP 1
	'Country' as [Source]
	, ctr.CountryName as [Winner]
	, COUNT(*) as [Number of events]
FROM
	tblEvent e
	INNER JOIN tblCountry ctr on e.CountryID = ctr.CountryID
GROUP BY
	ctr.CountryName
ORDER BY
	COUNT(*) DESC


-- top events continent
INSERT INTO @WinnerTable (
	Source
	, Winner
	, [Number of events]
)
SELECT TOP 1
	'Continent' as [Source]
	, cnt.ContinentName as [Winner]
	, COUNT(*) as [Number of events]
FROM
	tblEvent e
	INNER JOIN tblCountry ctr on e.CountryID = ctr.CountryID
	INNER JOIN tblContinent cnt	on ctr.ContinentID = cnt.ContinentID
GROUP BY
	cnt.ContinentName
ORDER BY
	COUNT(*) DESC


SELECT * FROM @WinnerTable