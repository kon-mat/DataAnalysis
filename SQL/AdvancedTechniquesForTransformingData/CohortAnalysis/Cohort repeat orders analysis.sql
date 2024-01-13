USE AdvancedTechniques
GO



--	-----[   ANALIZA POWROTÓW (PONOWNYCH ZAKUPÓW)   ]-----


--	1. Najpierw tworzymy tabelê z wielkoœci¹ kohort reprezentantów w podziale na stulecia
SELECT

	CASE
	  WHEN DATEPART(year, lt2.first_term) BETWEEN 1701 AND 1800 THEN 18
    WHEN DATEPART(year, lt2.first_term) BETWEEN 1801 AND 1900 THEN 19
		WHEN DATEPART(year, lt2.first_term) BETWEEN 1901 AND 2000 THEN 20
		WHEN DATEPART(year, lt2.first_term) BETWEEN 2001 AND 2100 THEN 21
	END AS [cohort_century],

	COUNT(lt2.id_bioguide) AS [reps]

FROM
	(
		-- Tabela z dat¹ rozpoczêcia pierwszej kadencji dla ka¿dego reprezentanta
		SELECT
			lt.id_bioguide,
			MIN(lt.term_start) AS [first_term]
		FROM
			legislators_terms lt
		WHERE
			lt.term_type = 'rep'
		GROUP BY
			lt.id_bioguide
	) lt2
GROUP BY
	CASE
	  WHEN DATEPART(year, lt2.first_term) BETWEEN 1701 AND 1800 THEN 18
    WHEN DATEPART(year, lt2.first_term) BETWEEN 1801 AND 1900 THEN 19
		WHEN DATEPART(year, lt2.first_term) BETWEEN 1901 AND 2000 THEN 20
		WHEN DATEPART(year, lt2.first_term) BETWEEN 2001 AND 2100 THEN 21
	END


--	2. Nastêpnie tworzymy tabelê w której wyszukujemy kohorty z cz³onkami,
--			którzy z reprezentantów zostali senatorami w przysz³oœci (musimy wykorzystaæ INNER JOIN do tej samej tabeli)
SELECT

	CASE
	  WHEN DATEPART(year, lt2.first_term) BETWEEN 1701 AND 1800 THEN 18
    WHEN DATEPART(year, lt2.first_term) BETWEEN 1801 AND 1900 THEN 19
		WHEN DATEPART(year, lt2.first_term) BETWEEN 1901 AND 2000 THEN 20
		WHEN DATEPART(year, lt2.first_term) BETWEEN 2001 AND 2100 THEN 21
	END AS [cohort_century],

	COUNT(lt2.id_bioguide) AS [rep_and_sen]

FROM
	(
		-- Tabela z dat¹ rozpoczêcia pierwszej kadencji dla ka¿dego cz³onka 'rep'
		SELECT
			lt.id_bioguide,
			MIN(lt.term_start) AS [first_term]
		FROM
			legislators_terms lt
		WHERE
			lt.term_type = 'rep'
		GROUP BY
			lt.id_bioguide
	) lt2

	INNER JOIN legislators_terms lt3
		ON lt2.id_bioguide = lt3.id_bioguide
		AND lt3.term_type = 'sen' AND lt3.term_start > lt2.first_term

GROUP BY
	CASE
	  WHEN DATEPART(year, lt2.first_term) BETWEEN 1701 AND 1800 THEN 18
    WHEN DATEPART(year, lt2.first_term) BETWEEN 1801 AND 1900 THEN 19
		WHEN DATEPART(year, lt2.first_term) BETWEEN 1901 AND 2000 THEN 20
		WHEN DATEPART(year, lt2.first_term) BETWEEN 2001 AND 2100 THEN 21
	END


--	3. Z³¹czamy oba podzapytania (1, 2) i obliczamy procent reprezentantów, którzy zostali senatorami	#!
--			dodajemy okno czasowe, aby uwzglêdniaæ tylko cz³onków z first_term minimum 10 lat temu

SELECT
	a.cohort_century,
	CAST(b.rep_and_sen AS float) / a.reps AS [pct_rep_and_sen]
FROM
(
	-- Tabela z wielkoœci¹ kohort reprezentantów w podziale na stulecia
	SELECT

		CASE
			WHEN DATEPART(year, lt2.first_term) BETWEEN 1701 AND 1800 THEN 18
			WHEN DATEPART(year, lt2.first_term) BETWEEN 1801 AND 1900 THEN 19
			WHEN DATEPART(year, lt2.first_term) BETWEEN 1901 AND 2000 THEN 20
			WHEN DATEPART(year, lt2.first_term) BETWEEN 2001 AND 2100 THEN 21
		END AS [cohort_century],

		COUNT(lt2.id_bioguide) AS [reps]

	FROM
		(
			-- Tabela z dat¹ rozpoczêcia pierwszej kadencji dla ka¿dego reprezentanta
			SELECT
				lt.id_bioguide,
				MIN(lt.term_start) AS [first_term]
			FROM
				legislators_terms lt
			WHERE
				lt.term_type = 'rep'
			GROUP BY
				lt.id_bioguide
		) lt2
	WHERE
		-- warunek okna czasowego
		lt2.first_term <= '2009-12-31'
	GROUP BY
		CASE
			WHEN DATEPART(year, lt2.first_term) BETWEEN 1701 AND 1800 THEN 18
			WHEN DATEPART(year, lt2.first_term) BETWEEN 1801 AND 1900 THEN 19
			WHEN DATEPART(year, lt2.first_term) BETWEEN 1901 AND 2000 THEN 20
			WHEN DATEPART(year, lt2.first_term) BETWEEN 2001 AND 2100 THEN 21
		END
) a

LEFT JOIN
(
	-- Tabela z cz³onkami, którzy z reprezentantów stali siê senatorami
	SELECT

		CASE
			WHEN DATEPART(year, lt2.first_term) BETWEEN 1701 AND 1800 THEN 18
			WHEN DATEPART(year, lt2.first_term) BETWEEN 1801 AND 1900 THEN 19
			WHEN DATEPART(year, lt2.first_term) BETWEEN 1901 AND 2000 THEN 20
			WHEN DATEPART(year, lt2.first_term) BETWEEN 2001 AND 2100 THEN 21
		END AS [cohort_century],

		COUNT(lt2.id_bioguide) AS [rep_and_sen]

	FROM
		(
			-- Tabela z dat¹ rozpoczêcia pierwszej kadencji dla ka¿dego cz³onka 'rep'
			SELECT
				lt.id_bioguide,
				MIN(lt.term_start) AS [first_term]
			FROM
				legislators_terms lt
			WHERE
				lt.term_type = 'rep'
			GROUP BY
				lt.id_bioguide
		) lt2

		INNER JOIN legislators_terms lt3
			ON lt2.id_bioguide = lt3.id_bioguide
			AND lt3.term_type = 'sen' AND lt3.term_start > lt2.first_term
	
	WHERE
		-- warunek okna czasowego
		DATEDIFF(year, lt2.first_term, lt3.term_start) <= 10
	GROUP BY
		CASE
			WHEN DATEPART(year, lt2.first_term) BETWEEN 1701 AND 1800 THEN 18
			WHEN DATEPART(year, lt2.first_term) BETWEEN 1801 AND 1900 THEN 19
			WHEN DATEPART(year, lt2.first_term) BETWEEN 1901 AND 2000 THEN 20
			WHEN DATEPART(year, lt2.first_term) BETWEEN 2001 AND 2100 THEN 21
		END
) b
	ON a.cohort_century = b.cohort_century