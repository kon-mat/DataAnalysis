USE WorldEvents
GO


WITH OccuredInSpace as (
	SELECT DISTINCT
		ctr.CountryName
		, cat.CategoryName
	FROM
		tblEvent e
		INNER JOIN tblCountry ctr on e.CountryID = ctr.CountryID
			and ctr.CountryName = 'Space'
		INNER JOIN tblCategory cat on e.CategoryID = cat.CategoryID
)

, NotOccuredInSpace as (
	SELECT DISTINCT
		e.EventName
		, ctr.CountryName
		, cat.CategoryName
	FROM
		tblEvent e
		INNER JOIN tblCountry ctr on e.CountryID = ctr.CountryID
			and ctr.CountryName != 'Space'
		INNER JOIN tblCategory cat on e.CategoryID = cat.CategoryID
)


SELECT * FROM NotOccuredInSpace
