USE WorldEvents
GO


-- get the ids of the 3 categories with the most events
WITH TopCategories as (
	SELECT TOP 3
		e.CategoryID
		, count(distinct e.EventID) as [EventCount]
	FROM
		tblEvent e
	GROUP BY
		e.CategoryID
	ORDER BY
		[EventCount] desc
)

-- get the ids of the 3 countries with the most events
, TopCountries as (
	SELECT TOP 3
		ctr.CountryID
		, count(distinct e.EventID) as [EventCount]
	FROM
		tblEvent e
		INNER JOIN tblCountry ctr on e.CountryID = ctr.CountryID
	GROUP BY
		ctr.CountryID
	ORDER BY
		[EventCount] desc
)

, TopCountriesCategories as (

	-- combine these together (every possible combination)
	SELECT
		ctr.CountryID,
		cat.CategoryID
	FROM
		TopCountries ctr
		CROSS JOIN TopCategories cat
)


-- count the number of events for each combination
SELECT
	ctr.CountryName
	, cat.CategoryName
	, count(distinct e.EventID) as [NumberEvents]
FROM
	tblEvent e
	INNER JOIN tblCountry ctr on e.CountryID = ctr.CountryID
	INNER JOIN tblCategory cat on e.CategoryID = cat.CategoryID

	INNER JOIN TopCountriesCategories tcc 
		on e.CountryID = tcc.CountryID and e.CategoryID = tcc.CategoryID

GROUP BY
	ctr.CountryName
	, cat.CategoryName
ORDER BY
	count(distinct e.EventID) desc