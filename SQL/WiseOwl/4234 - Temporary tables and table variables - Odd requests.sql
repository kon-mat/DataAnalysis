USE WorldEvents
GO


DECLARE @OddCountries TABLE (
	OddName varchar(100)
	, OddID int
)


INSERT INTO @OddCountries (
	OddName
	, OddID
)
SELECT
	DISTINCT ctr.CountryName
	, ctr.CountryID
FROM
	tblEvent e
	INNER JOIN tblCountry ctr on e.CountryID = ctr.CountryID
WHERE
	ctr.CountryID % 2 = 1


SELECT 
	e.EventName
	, oc.OddName
FROM 
	@OddCountries oc
	INNER JOIN tblEvent e on e.CountryID = oc.OddID
WHERE
	e.EventName not like '%' + oc.OddName + '%'
	and right(e.EventName, 1) = right(oc.OddName, 1)