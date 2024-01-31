USE WorldEvents
GO


WITH ManyCountries as (
	SELECT
		cnt.ContinentName
		, count(distinct ctr.CountryID) as CountryCount
	FROM
		tblCountry ctr
		INNER JOIN tblContinent cnt on ctr.ContinentID = cnt.ContinentID
	GROUP BY
		cnt.ContinentName
	HAVING
		count(distinct ctr.CountryID) >= 3
)

, FewEvents as (
	SELECT
		cnt.ContinentName
		, count(distinct e.EventID) as EventCount
	FROM
		tblEvent e
		INNER JOIN tblCountry ctr on e.CountryID = ctr.CountryID
		INNER JOIN tblContinent cnt on ctr.ContinentID = cnt.ContinentID
	GROUP BY
		cnt.ContinentName
	HAVING
		count(distinct e.EventID) <= 10
)


SELECT
	m.ContinentName
FROM 
	ManyCountries m
	INNER JOIN FewEvents f on m.ContinentName = f.ContinentName