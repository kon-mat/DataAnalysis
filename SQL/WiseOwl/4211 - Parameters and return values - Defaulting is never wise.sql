USE WorldEvents
GO


ALTER PROC spContinentEvents (
	@Continent VARCHAR(100) = NULL,
	@AfterDate DATE = NULL,
	@BeforeDate DATE = NULL
)
AS

SELECT
	cnt.ContinentName,
	e.EventName,
	e.EventDate
FROM
	tblEvent e

	INNER JOIN tblCountry ctr
		ON e.CountryID = ctr.CountryID

	INNER JOIN tblContinent cnt
		ON ctr.ContinentID = cnt.ContinentID

WHERE
	(cnt.ContinentName LIKE '%' + @Continent + '%'
	OR @Continent IS NULL)
	AND
	(e.EventDate >= @AfterDate
	OR @AfterDate IS NULL)
	AND
	(e.EventDate <= @BeforeDate
	OR @BeforeDate IS NULL)

GO


-- All events
spContinentEvents
GO

-- After or in 1990-01-01
spContinentEvents
	@AfterDate = '1990-01-01'
GO

spContinentEvents
	@Continent = 'Europe',
	@AfterDate = '1990-01-01',
	@BeforeDate = '2000-01-01'
GO