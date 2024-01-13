USE AdvancedTechniques
GO



--	-----[   ANALIZA PRZEKROJOWA W KONTEKŒCIE ANALIZY KOHORTOWEJ   ]-----


--	1. Tabela z kohortami stworzonymi na podstawie stulecia oraz stosunkiem ich cz³onków z konkretnego stulecia w danej dacie
SELECT
	lt4.date,
	lt4.century,
	lt4.legislators,

	SUM(lt4.legislators) OVER (
		PARTITION BY lt4.date
	) AS [cohort],

	CAST(lt4.legislators AS float) /
		SUM(lt4.legislators) OVER (
			PARTITION BY lt4.date
		) AS [pct_century]

FROM
	(
		-- Tabela z kohortami i ich wielkoœci¹ w podziale datê, stulecie 
		SELECT
			y.year_date AS [date],

			CASE
				WHEN DATEPART(year, lt2.first_term) BETWEEN 1701 AND 1800 THEN 18
				WHEN DATEPART(year, lt2.first_term) BETWEEN 1801 AND 1900 THEN 19
				WHEN DATEPART(year, lt2.first_term) BETWEEN 1901 AND 2000 THEN 20
				WHEN DATEPART(year, lt2.first_term) BETWEEN 2001 AND 2100 THEN 21
			END AS [century],

			COUNT(DISTINCT lt3.id_bioguide) AS [legislators]

		FROM
			legislators_terms lt3

			INNER JOIN YearlyCalendar y
				ON y.year_date BETWEEN lt3.term_start AND lt3.term_end
				AND YEAR(y.year_date) <= 2019

			INNER JOIN (
				SELECT
					lt.id_bioguide,
					MIN(lt.term_start) AS [first_term]
				FROM 
					legislators_terms lt
				GROUP BY
					lt.id_bioguide
			) lt2
				ON lt3.id_bioguide = lt2.id_bioguide

		GROUP BY
			y.year_date,

			CASE
				WHEN DATEPART(year, lt2.first_term) BETWEEN 1701 AND 1800 THEN 18
				WHEN DATEPART(year, lt2.first_term) BETWEEN 1801 AND 1900 THEN 19
				WHEN DATEPART(year, lt2.first_term) BETWEEN 1901 AND 2000 THEN 20
				WHEN DATEPART(year, lt2.first_term) BETWEEN 2001 AND 2100 THEN 21
			END
	) lt4


--	OUTPUT:
--		date				century	legislators	cohort	pct_century
--		1801-12-31	18			97					154			0.62987012987013
--		1801-12-31	19			57					154			0.37012987012987
--		1802-12-31	18			92					151			0.609271523178808
--		1802-12-31	19			59					151			0.390728476821192
--		1803-12-31	18			68					184			0.369565217391304


-- 2. Mo¿emy wykorzystaæ podejœcie, które umo¿liwi nam rozbicie na kolumny % kohort z danego stulecia
SELECT
	lt4.date,

	COALESCE(
		CAST(
			SUM(
				CASE 
					WHEN lt4.century = 18 THEN lt4.legislators 
				END
			) 
		AS float) / SUM(lt4.legislators)
	, 0) AS [pct_18],

	COALESCE(
		CAST(
			SUM(
				CASE 
					WHEN lt4.century = 19 THEN lt4.legislators 
				END
			) 
		AS float) / SUM(lt4.legislators)
	, 0) AS [pct_19],
	
	COALESCE(
		CAST(
			SUM(
				CASE 
					WHEN lt4.century = 20 THEN lt4.legislators 
				END
			) 
		AS float) / SUM(lt4.legislators)
	, 0) AS [pct_20],
	
	COALESCE(
		CAST(
			SUM(
				CASE 
					WHEN lt4.century = 21 THEN lt4.legislators 
				END
			) 
		AS float) / SUM(lt4.legislators)
	, 0) AS [pct_21]
	
FROM
	(
		-- Tabela z kohortami i ich wielkoœci¹ w podziale datê, stulecie 
		SELECT
			y.year_date AS [date],

			CASE
				WHEN DATEPART(year, lt2.first_term) BETWEEN 1701 AND 1800 THEN 18
				WHEN DATEPART(year, lt2.first_term) BETWEEN 1801 AND 1900 THEN 19
				WHEN DATEPART(year, lt2.first_term) BETWEEN 1901 AND 2000 THEN 20
				WHEN DATEPART(year, lt2.first_term) BETWEEN 2001 AND 2100 THEN 21
			END AS [century],

			COUNT(DISTINCT lt3.id_bioguide) AS [legislators]

		FROM
			legislators_terms lt3

			INNER JOIN YearlyCalendar y
				ON y.year_date BETWEEN lt3.term_start AND lt3.term_end
				AND YEAR(y.year_date) <= 2019

			INNER JOIN (
				SELECT
					lt.id_bioguide,
					MIN(lt.term_start) AS [first_term]
				FROM 
					legislators_terms lt
				GROUP BY
					lt.id_bioguide
			) lt2
				ON lt3.id_bioguide = lt2.id_bioguide

		GROUP BY
			y.year_date,

			CASE
				WHEN DATEPART(year, lt2.first_term) BETWEEN 1701 AND 1800 THEN 18
				WHEN DATEPART(year, lt2.first_term) BETWEEN 1801 AND 1900 THEN 19
				WHEN DATEPART(year, lt2.first_term) BETWEEN 1901 AND 2000 THEN 20
				WHEN DATEPART(year, lt2.first_term) BETWEEN 2001 AND 2100 THEN 21
			END
	) lt4

GROUP BY
	lt4.date


--	OUTPUT:
--		date				pct_18						pct_19						pct_20	pct_21
--		1801-12-31	0.62987012987013	0.37012987012987	0				0
--		1802-12-31	0.609271523178808	0.390728476821192	0				0
--		1803-12-31	0.369565217391304	0.630434782608696	0				0
--		1804-12-31	0.377659574468085	0.622340425531915	0				0


-- 3. Analiza kohort na podstawie iloœci lat urzêdowania w danym okresie
SELECT
	lt4.date,
	lt4.tenure,

	CAST(lt4.legislators AS float) / 
		SUM(lt4.legislators) OVER (
			PARTITION BY lt4.date
		) AS [pct.legislators]

FROM
(
	-- Tabela z kohortami na podstawie iloœci lat skumulowanych w danym roku (ilu cz³onków w roku X zasiada od Y lat)
	SELECT
		lt3.date,
	
		CASE
			WHEN lt3.cume_years <= 4 THEN '1 to 4'
			WHEN lt3.cume_years <= 10 THEN '5 to 10'
			WHEN lt3.cume_years <= 20 THEN '11 to 20'
			ELSE '21+'
		END AS [tenure],

		COUNT(DISTINCT lt3.id_bioguide) AS [legislators]

	FROM
		(
			-- Tabela z cz³onkami i skumulowan¹ wartoœci¹ liczby lat urzêdowania w ka¿dym roku
			SELECT
				lt2.id_bioguide,
				lt2.date,
				COUNT(lt2.date) OVER (
					PARTITION BY lt2.id_bioguide
					ORDER BY lt2.date ROWS BETWEEN
						UNBOUNDED PRECEDING AND CURRENT ROW
				) AS [cume_years]

			FROM
				(
					--	Tabela z cz³onkami i konkretnymi latami ich urzêdowania
					SELECT 
						DISTINCT lt.id_bioguide, 
						y.year_date AS [date]
					FROM 
						legislators_terms lt

						INNER JOIN YearlyCalendar y
							ON y.year_date BETWEEN lt.term_start AND lt.term_end
							AND YEAR(y.year_date) <= 2019
					GROUP BY
						lt.id_bioguide, 
						y.year_date
				) lt2
		) lt3

	GROUP BY
		lt3.date,
	
		CASE
			WHEN lt3.cume_years <= 4 THEN '1 to 4'
			WHEN lt3.cume_years <= 10 THEN '5 to 10'
			WHEN lt3.cume_years <= 20 THEN '11 to 20'
			ELSE '21+'
		END
) lt4


--	OUTPUT:
--		date				tenure		pct_legislators
--		1793-12-31	1 to 4		0.737588652482269
--		1793-12-31	5 to 10		0.26241134751773
--		1794-12-31	1 to 4		0.735714285714286
--		1794-12-31	5 to 10		0.264285714285714
--		1795-12-31	1 to 4		0.662068965517241