USE AdvancedTechniques
GO



--	-----[   ANALIZA PRZE¯YWALNOŒCI   ]-----


--	1. Zaczynamy od wyznaczenia dat pierwszej i ostatniej kadencji cz³onka, 
--			a nastêpnie obliczamy czas urzêdowania jako liczbê lat miêdzy pocz¹tkiem a koñcem dat
SELECT
	lt.id_bioguide,

	CASE
	  WHEN DATEPART(year, MIN(lt.term_start)) BETWEEN 1701 AND 1800 THEN 18
    WHEN DATEPART(year, MIN(lt.term_start)) BETWEEN 1801 AND 1900 THEN 19
		WHEN DATEPART(year, MIN(lt.term_start)) BETWEEN 1901 AND 2000 THEN 20
		WHEN DATEPART(year, MIN(lt.term_start)) BETWEEN 2001 AND 2100 THEN 21
	END AS [first_century],

	MIN(lt.term_start) AS [first_term],
	MAX(lt.term_end) AS [last_term],
	DATEDIFF(year, MIN(lt.term_start), MAX(lt.term_end)) AS [tenure]
FROM
	legislators_terms lt
GROUP BY
	lt.id_bioguide



--	1. Obliczamy % dla kohort na podstawie kadencji przez 10 lat
SELECT
	lt2.first_century,
	COUNT(DISTINCT lt2.id_bioguide) AS [cohort_size],
	
	-- tylko cz³onkowie z kadencj¹ na przynajmniej 10 lat
	COUNT(DISTINCT
		CASE
			WHEN lt2.tenure >= 10 THEN lt2.id_bioguide
		END
	) AS [survived_10],

	-- % cz³onków z kadencj¹ na przynajmniej 10 lat
	CAST(COUNT(DISTINCT
		CASE
			WHEN lt2.tenure >= 10 THEN lt2.id_bioguide
		END
	) AS float) / 
		COUNT(DISTINCT lt2.id_bioguide) AS [pct_survived_10]

FROM
(
	SELECT
		lt.id_bioguide,

		CASE
			WHEN DATEPART(year, MIN(lt.term_start)) BETWEEN 1701 AND 1800 THEN 18
			WHEN DATEPART(year, MIN(lt.term_start)) BETWEEN 1801 AND 1900 THEN 19
			WHEN DATEPART(year, MIN(lt.term_start)) BETWEEN 1901 AND 2000 THEN 20
			WHEN DATEPART(year, MIN(lt.term_start)) BETWEEN 2001 AND 2100 THEN 21
		END AS [first_century],

		MIN(lt.term_start) AS [first_term],
		MAX(lt.term_end) AS [last_term],
		DATEDIFF(year, MIN(lt.term_start), MAX(lt.term_end)) AS [tenure]
	FROM
		legislators_terms lt
	GROUP BY
		lt.id_bioguide
) lt2
GROUP BY
	lt2.first_century


--		OUTPUT:
--	century	cohort	survived_10	pct_survived_10
--	18			368			112					0.304347826086957
--	19			6299		1276				0.202571836799492
--	20			5091		2446				0.480455706148105
--	21			760			239					0.314473684210526



--	2. Kohorty na podstawie przynajmniej 5 obytych kadencji
SELECT
	lt2.first_century,
	COUNT(DISTINCT lt2.id_bioguide) AS [cohort_size],
	
	-- tylko cz³onkowie z kadencj¹ na przynajmniej 10 lat
	COUNT(DISTINCT
		CASE
			WHEN lt2.total_terms >= 5 THEN lt2.id_bioguide
		END
	) AS [survived_5],

	-- % cz³onków z kadencj¹ na przynajmniej 10 lat
	CAST(COUNT(DISTINCT
		CASE
			WHEN lt2.total_terms >= 5 THEN lt2.id_bioguide
		END
	) AS float) / 
		COUNT(DISTINCT lt2.id_bioguide) AS [pct_survived_5]

FROM
(
	SELECT
		lt.id_bioguide,

		CASE
			WHEN DATEPART(year, MIN(lt.term_start)) BETWEEN 1701 AND 1800 THEN 18
			WHEN DATEPART(year, MIN(lt.term_start)) BETWEEN 1801 AND 1900 THEN 19
			WHEN DATEPART(year, MIN(lt.term_start)) BETWEEN 1901 AND 2000 THEN 20
			WHEN DATEPART(year, MIN(lt.term_start)) BETWEEN 2001 AND 2100 THEN 21
		END AS [first_century],

		COUNT(lt.term_start) AS [total_terms]
	FROM
		legislators_terms lt
	GROUP BY
		lt.id_bioguide
) lt2
GROUP BY
	lt2.first_century


--		OUTPUT:
--	century	cohort	survived_5	pct_survived_5
--	18			368			63					0.171195652173913
--	19			6299		711					0.112875059533259
--	20			5091		2153				0.422903162443528
--	21			760			205					0.269736842105263





