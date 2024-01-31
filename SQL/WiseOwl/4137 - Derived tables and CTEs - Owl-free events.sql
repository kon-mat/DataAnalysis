USE WorldEvents
GO


WITH NoOwlEvents as (
	SELECT
		e.EventId
		, e.EventName
		, e.EventDate
		, e.CountryID
		, e.CategoryID
	FROM
		tblEvent e
	WHERE
		e.EventDetails not like '%o%' 
		and e.EventDetails not like '%w%'
		and e.EventDetails not like '%l%' 
)

, DefinedCountriesEvents as (
	SELECT
		e.EventId
		, e.EventName
		, e.EventDate
		, e.CountryID
		, e.CategoryID
	FROM
		tblEvent e
		INNER JOIN NoOwlEvents noe on e.CountryID = noe.CountryID
)


, DefinedCategoriesEvents as (
	SELECT DISTINCT
		e.EventName
		, e.EventDate
		, cat.CategoryName
		, ctr.CountryName
	FROM
		tblEvent e
		INNER JOIN DefinedCountriesEvents dce on e.CategoryID = dce.CategoryID
		INNER JOIN tblCategory cat on e.CategoryID = cat.CategoryID
		INNER JOIN tblCountry ctr on e.CountryID = ctr.CountryID
)


SELECT * 
FROM DefinedCategoriesEvents 
ORDER BY EventDate asc
