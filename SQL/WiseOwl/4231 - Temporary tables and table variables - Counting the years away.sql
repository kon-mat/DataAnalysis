USE WorldEvents
GO


IF object_id('tempdb.dbo.#MostEventfulCountry','U') is not null
	DROP TABLE #MostEventfulCountry

CREATE TABLE #MostEventfulCountry (
	[Year of events] int
	, [Country of events] varchar(100)
	, [Number of events] int
)

-- variable with the earliest event year
DECLARE @EventYear int = (
	SELECT year(min(EventDate)) FROM tblEvent
)

-- variable with the lastest event year
DECLARE @LastYear int = (
	SELECT year(max(EventDate)) FROM tblEvent
)



WHILE @EventYear <= @LastYear
	BEGIN

		INSERT INTO #MostEventfulCountry (
			[Year of events]
			, [Country of events]
			, [Number of events] 			
		)
		SELECT top 1
			@EventYear
			, c.CountryName
			, count(distinct e.EventID)
		FROM
			tblEvent e
			INNER JOIN tblCountry c on e.CountryID = c.CountryID
		WHERE
			year(e.EventDate) = @EventYear
		GROUP BY
			c.CountryName
		ORDER BY
			count(distinct e.EventID) DESC

		SET @EventYear = @EventYear + 1

	END


SELECT * FROM #MostEventfulCountry