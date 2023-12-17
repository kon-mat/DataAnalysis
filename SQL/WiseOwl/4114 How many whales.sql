
SELECT
	c.Country,
	c.KmSquared,

	-- the number of times the Wales area divided the country area
	(c.KmSquared - c.KmSquared % 20761) / 20761 AS WalesUnits,

	-- divide area of country by area of Wales, and the % operator leaves remainder
	c.KmSquared % 20761 AS AreaLeftOver,
	
	CASE
		WHEN c.KmSquared < 20761 THEN
			'Smaller than Wales'
		ELSE
			CAST((c.KmSquared - c.KmSquared % 20761) / 20761 AS VARCHAR(100)) +
				' x Wales plus ' +
				CAST(c.KmSquared % 20761 AS VARCHAR(100)) +
				' sq. km.'
	END AS WalesComparison

FROM
	WorldEvents.dbo.CountriesByArea c
ORDER BY
	-- order by closeness in size to Wales
	ABS(c.KmSquared - 20761)
