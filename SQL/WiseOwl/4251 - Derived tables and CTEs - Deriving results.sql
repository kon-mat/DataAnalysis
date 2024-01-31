USE WorldEvents
GO


WITH Second_Half_Derived as (
	SELECT
		e.EventName
		, e.CountryID
	FROM
		tblEvent e
	WHERE
		e.EventName like '%[N-Z]'
)


SELECT 
	c.CountryName
	, s.EventName
FROM 
	Second_Half_Derived s
	INNER JOIN tblCountry c on s.CountryID = c.CountryID