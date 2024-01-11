USE AdvancedTechniques
GO



--	-----[   DEFINIOWANIE KOHORT NA PODSTAWIE ODRÊBNEJ TABELI   ]-----


--	1. Zdefiniowanie kohort na podstawie p³ci (odrêbna tabela) 
SELECT
	lt4.gender,
	lt4.period,

	FIRST_VALUE(lt4.cohort_retained) OVER (
		PARTITION BY lt4.gender
		ORDER BY lt4.period
	) AS [cohort_size],

	lt4.cohort_retained,

	CAST(lt4.cohort_retained AS float) /
	FIRST_VALUE(lt4.cohort_retained) OVER (
		PARTITION BY lt4.gender
		ORDER BY lt4.period
	) AS [pct_retained]

FROM
(
	-- Tabela z wielkoœci¹ kohort na podstawie okresu i p³ci
	SELECT
		l.gender,
		COALESCE(DATEDIFF(year, lt2.first_term, y.year_date), 0) AS [period],
		COUNT(DISTINCT lt2.id_bioguide) AS [cohort_retained]
	FROM
		(
			-- Tabela z id danego polityka i jego dat¹ rozpoczêcia kadencji
			SELECT
				lt.id_bioguide,
				MIN(lt.term_start) AS [first_term]
			FROM
				legislators_terms lt
			GROUP BY
				lt.id_bioguide
		) lt2

		INNER JOIN legislators_terms lt3
			ON lt2.id_bioguide = lt3.id_bioguide

		LEFT JOIN YearlyCalendar y
			ON y.year_date BETWEEN lt3.term_start AND lt3.term_end

		-- Tabela do pobrania p³ci cz³onków
		INNER JOIN legislators l
			ON lt2.id_bioguide = l.id_bioguide

	GROUP BY
		l.gender,
		COALESCE(DATEDIFF(year, lt2.first_term, y.year_date), 0)
) lt4


-- OUTPUT:
--		gender	period	cohort_sioze	cohort_retained	pct_retained
--		F				0				366						366							1
--		F				1				366						349							0.953551912568306
--		F				2				366						261							0.713114754098361
--		F				3				366						256							0.699453551912568
--		F				4				366						219							0.598360655737705
--		F				5				366						218							0.595628415300546
--		F				6				366						177							0.483606557377049


-- 1. Poniewa¿ kohorta kobiet pojawi³a siê w sejmie od roku 1917,
--		to trzeba przy takim rozbiciu analizowaæ wy³acznie zakres,
--		w który wystêpowa³y obie kohorty, aby otrzymaæ spójne dane	 #!
SELECT
	lt4.gender,
	lt4.period,

	FIRST_VALUE(lt4.cohort_retained) OVER (
		PARTITION BY lt4.gender
		ORDER BY lt4.period
	) AS [cohort_size],

	lt4.cohort_retained,

	CAST(lt4.cohort_retained AS float) /
	FIRST_VALUE(lt4.cohort_retained) OVER (
		PARTITION BY lt4.gender
		ORDER BY lt4.period
	) AS [pct_retained]

FROM
(
	-- Tabela z wielkoœci¹ kohort na podstawie okresu i p³ci
	SELECT
		l.gender,
		COALESCE(DATEDIFF(year, lt2.first_term, y.year_date), 0) AS [period],
		COUNT(DISTINCT lt2.id_bioguide) AS [cohort_retained]
	FROM
		(
			-- Tabela z id danego polityka i jego dat¹ rozpoczêcia kadencji
			SELECT
				lt.id_bioguide,
				MIN(lt.term_start) AS [first_term]
			FROM
				legislators_terms lt
			GROUP BY
				lt.id_bioguide
		) lt2

		INNER JOIN legislators_terms lt3
			ON lt2.id_bioguide = lt3.id_bioguide

		LEFT JOIN YearlyCalendar y
			ON y.year_date BETWEEN lt3.term_start AND lt3.term_end

		INNER JOIN legislators l
			ON lt2.id_bioguide = l.id_bioguide

	WHERE
		-- Warunek dla okresu, gdy kobiety ju¿ by³y cz³onkiniami
		lt2.first_term BETWEEN '1917-01-01' AND '1992-12-31'
	GROUP BY
		l.gender,
		COALESCE(DATEDIFF(year, lt2.first_term, y.year_date), 0)
) lt4



--	-----[   KOHORTY RZADKIE, KTÓRE PRZY ROZBICIU WYNASZ¥ 0 W DANYM OKRESIE   ]-----


-- 1. Tworzymy kohorty z podzia³em na stan i p³eæ (uzyskamy kohorty rzadkie)
SELECT
	lt3.first_state,
	lt3.gender,
	lt3.period,
	
	FIRST_VALUE(lt3.cohort_retained) OVER (
		PARTITION BY 	lt3.first_state, lt3.gender
		ORDER BY lt3.period
	) AS [cohort_size],

	lt3.cohort_retained,

	CAST(lt3.cohort_retained AS float) /
	FIRST_VALUE(lt3.cohort_retained) OVER (
		PARTITION BY 	lt3.first_state, lt3.gender
		ORDER BY lt3.period
	) AS [pct_retained]

FROM
(
	-- Tabela z wielkoœci¹ kohort w danym okresie (podzia³ na stan i p³eæ)
	SELECT
		lt2.first_state,
		l.gender,
		COALESCE(DATEDIFF(year, lt2.first_term, y.year_date), 0) AS [period],
		COUNT(DISTINCT lt2.id_bioguide) AS [cohort_retained]
	FROM
		(
			-- Tabela z cz³onkami kongresu, pierwsz¹ dat¹ rozpoczêcia kadencji i stanem tej pierwszej kadencji

			SELECT
				DISTINCT lt.id_bioguide,
				
				MIN(lt.term_start) OVER (
					PARTITION BY lt.id_bioguide
				) AS [first_term],

				FIRST_VALUE(lt.state) OVER (
					PARTITION BY lt.id_bioguide
					ORDER BY lt.term_start
				) AS [first_state]

			FROM
				legislators_terms lt
		) lt2

		INNER JOIN legislators_terms lt3
			ON lt2.id_bioguide = lt3.id_bioguide

		LEFT JOIN YearlyCalendar y
			ON y.year_date BETWEEN lt3.term_start AND lt3.term_end

		INNER JOIN legislators l
			ON lt2.id_bioguide = l.id_bioguide

	WHERE
		-- Warunek dla okresu, gdy kobiety ju¿ by³y cz³onkiniami
		lt2.first_term BETWEEN '1917-01-01' AND '1992-12-31'
	GROUP BY
		lt2.first_state,
		l.gender,
		COALESCE(DATEDIFF(year, lt2.first_term, y.year_date), 0)
) lt3




-- 2. Najpierw pobieramy wszystkie kombinacje okresów i atrybutów kohort
SELECT
	lt3.gender,
	lt3.first_state,
	s.period,
	lt3.cohort_size
FROM
(
	-- Tabela z wielkoœci¹ kohort w podziale na stan i p³eæ
	SELECT
		l.gender,
		lt2.first_state,
		COUNT(DISTINCT lt2.id_bioguide) AS [cohort_size]
	FROM
	(
		-- Tabela z cz³onkami kongresu, pierwsz¹ dat¹ rozpoczêcia kadencji i stanem tej pierwszej kadencji
		SELECT
			DISTINCT lt.id_bioguide,

			MIN(lt.term_start) OVER (
				PARTITION BY lt.id_bioguide
			) AS [first_term],
	
			FIRST_VALUE(lt.state) OVER (
				PARTITION BY lt.id_bioguide
				ORDER BY lt.term_start
			) AS [first_state]

		FROM
			legislators_terms lt
	) lt2

	INNER JOIN legislators l
		ON lt2.id_bioguide = l.id_bioguide

	WHERE
		lt2.first_term BETWEEN '1917-01-01' AND '1992-12-31'
	GROUP BY
		l.gender,
		lt2.first_state
) lt3

-- Tabela do iloczynu kartezjañskiego i z³¹czenia lt3 z ka¿dym z okresów 0-20
INNER JOIN (
	-- Polecenie do wygenerowania liczb z zakresu 0-20
	SELECT 
		TOP(21) ROW_NUMBER() OVER (
			ORDER BY (SELECT NULL)
		) - 1 AS period
	FROM 
		master..spt_values
	)	s
	-- Sposób na wymuszenie iloczynu kartezjañskiego 1 = 1
	ON 1 = 1


-- OUTPUT:
--		gender	first_state	period	cohort_size
--		M				AK					0				13
--		M				AK					1				13
--		M				AK					2				13


-- 3. Nastêpnie ³¹czymy powy¿sze dane z okresami urzêdowania. 
--		U¿ywamy LEFT JOIN, aby w ostatecznych wynikach zosta³y zachowane wszystkie orkesy.
SELECT
	a.gender,
	a.first_state,
	a.period,
	a.cohort_size,
	COALESCE(b.cohort_retained, 0) AS [cohort_retained],

	CAST(COALESCE(b.cohort_retained, 0) AS float) /
	a.cohort_size AS [pct_retained]

FROM
( 
	-- Tabela z pkt 1
	SELECT
		lt3.gender,
		lt3.first_state,
		s.period,
		lt3.cohort_size
	FROM
	(
		-- Tabela z wielkoœci¹ kohort w podziale na stan i p³eæ
		SELECT
			l.gender,
			lt2.first_state,
			COUNT(DISTINCT lt2.id_bioguide) AS [cohort_size]
		FROM
		(
			-- Tabela z cz³onkami kongresu, pierwsz¹ dat¹ rozpoczêcia kadencji i stanem tej pierwszej kadencji
			SELECT
				DISTINCT lt.id_bioguide,

				MIN(lt.term_start) OVER (
					PARTITION BY lt.id_bioguide
				) AS [first_term],
	
				FIRST_VALUE(lt.state) OVER (
					PARTITION BY lt.id_bioguide
					ORDER BY lt.term_start
				) AS [first_state]

			FROM
				legislators_terms lt
		) lt2

		INNER JOIN legislators l
			ON lt2.id_bioguide = l.id_bioguide

		WHERE
			lt2.first_term BETWEEN '1917-01-01' AND '1992-12-31'
		GROUP BY
			l.gender,
			lt2.first_state
	) lt3

	-- Tabela do iloczynu kartezjañskiego i z³¹czenia lt3 z ka¿dym z okresów 0-20
	INNER JOIN (
		-- Polecenie do wygenerowania liczb z zakresu 0-20
		SELECT 
			TOP(21) ROW_NUMBER() OVER (
				ORDER BY (SELECT NULL)
			) - 1 AS period
		FROM 
			master..spt_values
		)	s
		-- Sposób na wymuszenie iloczynu kartezjañskiego 1 = 1
		ON 1 = 1
) a

LEFT JOIN (
	-- Tabela z pkt 2
	SELECT
		lt3.first_state,
		lt3.gender,
		lt3.period,
	
		FIRST_VALUE(lt3.cohort_retained) OVER (
			PARTITION BY 	lt3.first_state, lt3.gender
			ORDER BY lt3.period
		) AS [cohort_size],

		lt3.cohort_retained,

		CAST(lt3.cohort_retained AS float) /
		FIRST_VALUE(lt3.cohort_retained) OVER (
			PARTITION BY 	lt3.first_state, lt3.gender
			ORDER BY lt3.period
		) AS [pct_retained]

	FROM
	(
		-- Tabela z wielkoœci¹ kohort w danym okresie (podzia³ na stan i p³eæ)
		SELECT
			lt2.first_state,
			l.gender,
			COALESCE(DATEDIFF(year, lt2.first_term, y.year_date), 0) AS [period],
			COUNT(DISTINCT lt2.id_bioguide) AS [cohort_retained]
		FROM
			(
				-- Tabela z cz³onkami kongresu, pierwsz¹ dat¹ rozpoczêcia kadencji i stanem tej pierwszej kadencji

				SELECT
					DISTINCT lt.id_bioguide,
				
					MIN(lt.term_start) OVER (
						PARTITION BY lt.id_bioguide
					) AS [first_term],

					FIRST_VALUE(lt.state) OVER (
						PARTITION BY lt.id_bioguide
						ORDER BY lt.term_start
					) AS [first_state]

				FROM
					legislators_terms lt
			) lt2

			INNER JOIN legislators_terms lt3
				ON lt2.id_bioguide = lt3.id_bioguide

			LEFT JOIN YearlyCalendar y
				ON y.year_date BETWEEN lt3.term_start AND lt3.term_end

			INNER JOIN legislators l
				ON lt2.id_bioguide = l.id_bioguide

		WHERE
			-- Warunek dla okresu, gdy kobiety ju¿ by³y cz³onkiniami
			lt2.first_term BETWEEN '1917-01-01' AND '1992-12-31'
		GROUP BY
			lt2.first_state,
			l.gender,
			COALESCE(DATEDIFF(year, lt2.first_term, y.year_date), 0)
	) lt3
) b
	ON a.period = b.period


-- OUTPUT:
--		gender	first_state	period	cohort_size	cohort_retained	pct_retained
--		M				AK					0				13					13							1
--		M				AK					0				13					3								0.230769230769231
--		M				AK					0				13					54							4.15384615384615
--		M				AK					0				13					4								0.307692307692308
--		M				AK					0				13					34							2.61538461538462
--		M				AK					0				13					2								0.153846153846154



--	-----[   DEFINIOWANIE KOHORT NA PODSTAWIE DATY INNEJ, NI¯ POCZ¥TKOWA   ]-----


--	1. Tabela z kohortami w podziale na term_type (zbudowana na konkretnej dacie pocz¹tkowej)
SELECT
	lt4.term_type,
	lt4.period,

	FIRST_VALUE(lt4.cohort_retained) OVER (
		PARTITION BY lt4.term_type
		ORDER BY lt4.period
	) AS [cohort_size],

	lt4.cohort_retained,

	CAST(lt4.cohort_retained AS float) /
		FIRST_VALUE(lt4.cohort_retained) OVER (
			PARTITION BY lt4.term_type
			ORDER BY lt4.period
		) AS [pct_retained]

FROM
	(
		-- Tabela z iloœci¹ kohort w danym okresie z podziale na typ kadencji (term_type)
		SELECT
			lt2.term_type,
			COALESCE(DATEDIFF(year, lt2.first_term, y.year_date), 0) AS [period],
			COUNT(DISTINCT lt2.id_bioguide) AS [cohort_retained]
		FROM
			(
				-- Tabela z ka¿dym cz³onkiem, jego rodzajem kadencji, okreœlon¹ dat¹ kohorty i min_start
				SELECT
					DISTINCT lt.id_bioguide,
					lt.term_type,
					CAST('2000-01-01' AS DATE) AS [first_term],
					MIN(lt.term_start) AS [min_start]
				FROM
					legislators_terms lt
				WHERE
					lt.term_start <= '2000-12-31' AND lt.term_end >= '2000-01-01'
				GROUP BY
					lt.id_bioguide,
					lt.term_type
			) lt2

			INNER JOIN legislators_terms lt3
				ON lt2.id_bioguide = lt3.id_bioguide

			LEFT JOIN YearlyCalendar y
				ON y.year_date BETWEEN lt3.term_start AND lt3.term_end
				AND YEAR(y.year_date) >= 2000

		GROUP BY
			lt2.term_type,
			COALESCE(DATEDIFF(year, lt2.first_term, y.year_date), 0)
	) lt4


--		OUTPUT:
--	term_type	period	cohort_size	cohort_retained	pct_retained
--	rep				0				440					440							1
--	rep				1				440					392							0.890909090909091
--	rep				2				440					389							0.884090909090909
--	rep				3				440					340							0.772727272727273
--	rep				4				440					338							0.768181818181818
--	rep				5				440					308							0.7

