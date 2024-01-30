USE AdvancedTechniques
GO



--	-----[   ZNAJDOWANIE ANOMALII ZA POMOC¥ SORTOWANIA   ]-----


--	1. Znajdowanie za pomoc¹ sortowania mo¿e byæ przydatne, 
--			ale czasami bez wiedzy specjalistycznej okazuje siê niewystarczaj¹ce
SELECT
	e.place,
	e.mag,
	COUNT(*) AS [count]
FROM 
	earthquakes e
WHERE
	e.mag IS NOT NULL
	AND e.place = 'Northern California'
GROUP BY
	e.place,
	e.mag
ORDER BY
	e.place,
	e.mag DESC


	--	OUTPUT:
	--place									mag			count
	--Northern California		5.6			1
	--Northern California		4.73		1
	--Northern California		4.51		1
	--Northern California		4.43		2
	--...										...			...
	--Northern California		-1			23
	--Northern California		-1.1		7
	--Northern California		-1.2		2
	--Northern California		-1.6		1



	--	-----[   ZNAJDOWANIE NA PODSTAWIE PERCENTYLI I ODCHYLENIA STANDARDOWEGO   ]-----


--	1. Wykorzystanie funkcji PERCENT_RANK() do zwrócenia percentyli
SELECT
	e2.place
	, e2.mag
	, e2.percentile
	, COUNT(*) AS [count]
FROM
	(
		SELECT
			e.place
			, e.mag

			-- funkcja PERCENT_RANK() zwraca percentyl dla ka¿dego wiersza grupy
			, PERCENT_RANK() OVER (
				PARTITION BY e.place
				ORDER BY e.mag
			) AS [percentile]

		FROM
			earthquakes e
		WHERE
			e.mag IS NOT NULL
			AND e.place = 'Northern California'
	) e2
GROUP BY
	e2.place
	, e2.mag
	, e2.percentile
ORDER BY
	e2.place
	, e2.mag DESC


	--	OUTPUT:
	--place									mag			percentile					count
	--Northern California		5.6			1										1
	--Northern California		4.73		0.999987059706514		1
	--Northern California		4.51		0.999974119413028		1
	--Northern California		4.43		0.999948238826057		2
	--Northern California		4.29		0.999935298532571		1
	--Northern California		4.28		0.999922358239085		1


--	2. Wykorzystanie funkcji NTILE(100) do zwrócenia percentyli
SELECT
	e2.place
	, e2.ntile
	, MAX(e2.mag) AS [maximum]
	, MIN(e2.mag) AS [minimum]
FROM
	(
		SELECT
			e.place
			, e.mag

			-- funkcja NTILE() dzieli zbiór danych na okreœlon¹ liczbê przedzia³ów 
			--	i okreœla do którego przedzia³u nale¿y dany wiersz
			, NTILE(4) OVER (
				PARTITION BY e.place
				ORDER BY e.mag
			) AS [ntile]

		FROM
			earthquakes e
		WHERE
			e.mag IS NOT NULL
			AND e.place = 'Central Alaska'
	) e2
GROUP BY
	e2.place
	, e2.ntile
ORDER BY
	e2.place
	, e2.ntile DESC


--		OUTPUT:
--	place						ntile		maximum		minimum
--	Central Alaska	4				5.4				1.4
--	Central Alaska	3				1.4				1.1
--	Central Alaska	2				1.1				0.8
--	Central Alaska	1				0.8				-0.5


--	3. Wykorzystanie funkcji PERCENTILE_CONT() do 
--			wyznaczenia wartoœci odpowiadaj¹cym okreœlonym percentylom dla ca³ego zbioru
--			Ta funkcja wymaga dodatkowo klauzuli WITHIN GROUP oraz standardowo OVER PARTITION BY
SELECT
	e2.place
	, MAX(e2.pct_25_mag) AS [pct_25_mag]
	, MAX(e2.pct_25_depth) AS [pct_25_depth]
	, MAX(e2.pct_50_mag) AS [pct_50_mag]
	, MAX(e2.pct_50_depth) AS [pct_50_depth]
	, MAX(e2.pct_75_mag) AS [pct_75_mag]
	, MAX(e2.pct_75_depth) AS [pct_75_depth]
FROM
	(
	SELECT
		e.place

		, PERCENTILE_CONT(0.25) WITHIN GROUP (
			ORDER BY e.mag
		) OVER (
			PARTITION BY e.place
		) AS [pct_25_mag]

		, PERCENTILE_CONT(0.25) WITHIN GROUP (
			ORDER BY e.depth
		) OVER (
			PARTITION BY e.place
		) AS [pct_25_depth]

		, PERCENTILE_CONT(0.50) WITHIN GROUP (
			ORDER BY e.mag
		) OVER (
			PARTITION BY e.place
		) AS [pct_50_mag]

		, PERCENTILE_CONT(0.50) WITHIN GROUP (
			ORDER BY e.depth
		) OVER (
			PARTITION BY e.place
		) AS [pct_50_depth]

		, PERCENTILE_CONT(0.75) WITHIN GROUP (
			ORDER BY e.mag
		) OVER (
			PARTITION BY e.place
		) AS [pct_75_mag]

		, PERCENTILE_CONT(0.75) WITHIN GROUP (
			ORDER BY e.depth
		) OVER (
			PARTITION BY e.place
		) AS [pct_75_depth]

	FROM
		earthquakes e
	WHERE
		e.mag IS NOT NULL
		AND e.place IN ('Central Alaska', 'Southern Alaska')
	GROUP BY
		e.place
		, e.mag
		, e.depth
	) e2
GROUP BY
	e2.place


--		OUTPUT:
--	place							25_m	25_d		50_m	50_d		75_m	75_d
--	Central Alaska		1			12.8		1.3		50.2		1.7		93.3
--	Southern Alaska		1.2		20.7		1.6		56.9		2			93.4


--	4. Wykorzystanie funkcji STDEV() (odchylenie standardowe) do okreœlenia anomalii
--			oraz obliczanie wskaŸnika z-score (odchylenie standardowe od œredniej dla wartoœci ze zbioru danych)
SELECT
	e2.place
	, e2.mag
	, e3.avg_mag
	, e3.std_dev
	, (e2.mag - e3.std_dev) / e3.std_dev AS [z_score]
FROM
	earthquakes e2

	INNER JOIN (
		SELECT
			AVG(e.mag) AS [avg_mag]
			, STDEV(e.mag) AS [std_dev]
		FROM	
			earthquakes e
		WHERE
			e.mag IS NOT NULL
	) e3
		ON 1 = 1

WHERE
	e2.mag IS NOT NULL
ORDER BY
	e2.mag DESC


--		OUTPUT:
--	place																		mag		avg_mag							std_dev							z_score
--	2011 Great Tohoku Earthquake, Japan			9.1		1.62510260811314		1.27360596468625		6.14506703982168
--	offshore Bio-Bio, Chile									8.8		1.62510260811314		1.27360596468625		5.90951537916822
--	off the west coast of northern Sumatra	8.6		1.62510260811314		1.27360596468625		5.75248093873258
--	48km W of Illapel, Chile								8.3		1.62510260811314		1.27360596468625		5.51692927807912
--	Sea of Okhotsk													8.3		1.62510260811314		1.27360596468625		5.51692927807912
--	94km NW of Iquique, Chile								8.2		1.62510260811314		1.27360596468625		5.43841205786129



--	5. Wykorzystanie percentyli do stworzenia danych dla wykresu pude³kowego
SELECT
	e3.ntile_25
	, e3.median
	, e3.ntile_75
	, ROUND((e3.ntile_75 - e3.ntile_25) * 1.5, 3) AS [iqr]
	, ROUND(e3.ntile_25 - (e3.ntile_75 - e3.ntile_25) * 1.5, 3) AS [lower_whisker]
	, ROUND(e3.ntile_75 - (e3.ntile_75 - e3.ntile_25) * 1.5, 3) AS [upper_whisker]
FROM
	(
		SELECT
			ROUND(AVG(e2.ntile_25), 3) AS [ntile_25]
			,	ROUND(AVG(e2.median), 3) AS [median]
			,	ROUND(AVG(e2.ntile_75), 3) AS [ntile_75]
		FROM
			(
				SELECT

					PERCENTILE_CONT(0.25) WITHIN GROUP (
						ORDER BY e.mag
					) OVER (
						PARTITION BY e.place
					) AS [ntile_25]

					, PERCENTILE_CONT(0.5) WITHIN GROUP (
						ORDER BY e.mag
					) OVER (
						PARTITION BY e.place
					) AS [median]

					, PERCENTILE_CONT(0.75) WITHIN GROUP (
						ORDER BY e.mag
					) OVER (
						PARTITION BY e.place
					) AS [ntile_75]

				FROM
					earthquakes e
				WHERE
					e.place LIKE '%Japan%'
			) e2
	) e3


--		OUTPUT:
--	ntile_25	median	ntile_75	iqr		lower_whisker		upper_whisker
--	4.406			4.549		4.679			0.41	3.996						4.269