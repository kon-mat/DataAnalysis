USE AdvancedTechniques
GO



--	-----[   ANALIZA Z WARTOŒCIAMI SKUMULOWANYMI   ]-----
--	wartoœci skumulowane przydaj¹ siê do analizy wartoœci ¿yciowej klienta
--	CLTV - cumulative lifetime value	;	LTV - customer lifetime value


--	1. Tabela z wielkoœci¹ kohort w podziale na senatorów i reprezentantów oraz
--			iloœæ¹ kadencji w ci¹gu 10 lat

SELECT 

	CASE
	  WHEN DATEPART(year, lt2.first_term) BETWEEN 1701 AND 1800 THEN 18
    WHEN DATEPART(year, lt2.first_term) BETWEEN 1801 AND 1900 THEN 19
		WHEN DATEPART(year, lt2.first_term) BETWEEN 1901 AND 2000 THEN 20
		WHEN DATEPART(year, lt2.first_term) BETWEEN 2001 AND 2100 THEN 21
	END AS [century],

	lt2.first_type,
	COUNT(DISTINCT lt2.id_bioguide) AS [cohort],
	COUNT(lt3.term_start) AS [terms]


FROM
	(
		-- Tabela z cz³onkami, ich pierwszym typem kadencji oraz dat¹ rozpoczêcia i dat¹ + 10 lat od rozpoczêcia
		SELECT
			DISTINCT lt.id_bioguide,
	
			FIRST_VALUE(lt.term_type) OVER (
				PARTITION BY lt.id_bioguide
				ORDER BY lt.term_start
			) AS [first_type],
	
	
			MIN(lt.term_start) OVER (
				PARTITION BY lt.id_bioguide
			) AS [first_term],


			DATEADD(year, 10, 
				MIN(lt.term_start) OVER (
					PARTITION BY lt.id_bioguide
				)
			) AS [first_plus_10]

		FROM
			legislators_terms lt
	) lt2

	LEFT JOIN legislators_terms lt3
		ON lt2.id_bioguide = lt3.id_bioguide
		AND lt3.term_start BETWEEN lt2.first_term AND lt2.first_plus_10

GROUP BY

	CASE
	  WHEN DATEPART(year, lt2.first_term) BETWEEN 1701 AND 1800 THEN 18
    WHEN DATEPART(year, lt2.first_term) BETWEEN 1801 AND 1900 THEN 19
		WHEN DATEPART(year, lt2.first_term) BETWEEN 1901 AND 2000 THEN 20
		WHEN DATEPART(year, lt2.first_term) BETWEEN 2001 AND 2100 THEN 21
	END,

	lt2.first_type


-- 2. Nastêpnie obliczamy na podstawie poprzedniej tabeli interesuj¹ce nas wartoœci	#!
--		Przydatne obliczenia: œrednia liczba dzia³añ na osobê, œrednia wartoœæ zamówienia,
--		liczba produktów na zamówienie, liczba zamówieñ na klienta
SELECT
	lt4.century,

	MAX(
		CASE
			WHEN lt4.first_type = 'rep' THEN lt4.cohort
		END
	) AS [rep_cohort],

	MAX(
		CASE
			WHEN lt4.first_type = 'rep' THEN lt4.terms_per_leg
		END
	) AS [avg_rep_terms],

	MAX(
		CASE
			WHEN lt4.first_type = 'sen' THEN lt4.cohort
		END
	) AS [sen_cohort],

	MAX(
		CASE
			WHEN lt4.first_type = 'sen' THEN lt4.terms_per_leg
		END
	) AS [avg_sen_terms]

FROM
	(
		-- Tabela z wielkoœci¹ kohort w podziale na senatorów i reprezentantów oraz iloœæ¹ kadencji w ci¹gu 10 lat
		SELECT 

			CASE
				WHEN DATEPART(year, lt2.first_term) BETWEEN 1701 AND 1800 THEN 18
				WHEN DATEPART(year, lt2.first_term) BETWEEN 1801 AND 1900 THEN 19
				WHEN DATEPART(year, lt2.first_term) BETWEEN 1901 AND 2000 THEN 20
				WHEN DATEPART(year, lt2.first_term) BETWEEN 2001 AND 2100 THEN 21
			END AS [century],

			lt2.first_type,
			COUNT(DISTINCT lt2.id_bioguide) AS [cohort],
			COUNT(lt3.term_start) AS [terms],

			CAST(COUNT(lt3.term_start) AS float) /
				COUNT(DISTINCT lt2.id_bioguide) AS [terms_per_leg]


		FROM
			(
				-- Tabela z cz³onkami, ich pierwszym typem kadencji oraz dat¹ rozpoczêcia i dat¹ + 10 lat od rozpoczêcia
				SELECT
					DISTINCT lt.id_bioguide,
	
					FIRST_VALUE(lt.term_type) OVER (
						PARTITION BY lt.id_bioguide
						ORDER BY lt.term_start
					) AS [first_type],
	
	
					MIN(lt.term_start) OVER (
						PARTITION BY lt.id_bioguide
					) AS [first_term],


					DATEADD(year, 10, 
						MIN(lt.term_start) OVER (
							PARTITION BY lt.id_bioguide
						)
					) AS [first_plus_10]

				FROM
					legislators_terms lt
			) lt2

			LEFT JOIN legislators_terms lt3
				ON lt2.id_bioguide = lt3.id_bioguide
				AND lt3.term_start BETWEEN lt2.first_term AND lt2.first_plus_10

		GROUP BY

			CASE
				WHEN DATEPART(year, lt2.first_term) BETWEEN 1701 AND 1800 THEN 18
				WHEN DATEPART(year, lt2.first_term) BETWEEN 1801 AND 1900 THEN 19
				WHEN DATEPART(year, lt2.first_term) BETWEEN 1901 AND 2000 THEN 20
				WHEN DATEPART(year, lt2.first_term) BETWEEN 2001 AND 2100 THEN 21
			END,

			lt2.first_type
	) lt4

GROUP BY
	lt4.century