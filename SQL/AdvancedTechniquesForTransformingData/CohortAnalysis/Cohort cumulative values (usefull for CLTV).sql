USE AdvancedTechniques
GO



--	-----[   ANALIZA Z WARTO�CIAMI SKUMULOWANYMI   ]-----
--	warto�ci skumulowane przydaj� si� do analizy warto�ci �yciowej klienta
--	CLTV - cumulative lifetime value	;	LTV - customer lifetime value


--	1. Tabela z wielko�ci� kohort w podziale na senator�w i reprezentant�w oraz
--			ilo�� kadencji w ci�gu 10 lat

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
		-- Tabela z cz�onkami, ich pierwszym typem kadencji oraz dat� rozpocz�cia i dat� + 10 lat od rozpocz�cia
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


-- 2. Nast�pnie obliczamy na podstawie poprzedniej tabeli interesuj�ce nas warto�ci	#!
--		Przydatne obliczenia: �rednia liczba dzia�a� na osob�, �rednia warto�� zam�wienia,
--		liczba produkt�w na zam�wienie, liczba zam�wie� na klienta
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
		-- Tabela z wielko�ci� kohort w podziale na senator�w i reprezentant�w oraz ilo�� kadencji w ci�gu 10 lat
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
				-- Tabela z cz�onkami, ich pierwszym typem kadencji oraz dat� rozpocz�cia i dat� + 10 lat od rozpocz�cia
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