USE AdvancedTechniques
GO



--	-----[   TWORZENIE KRZYWEJ UTRZYMANIA   ]-----


--	1. Krzywa utrzymania w kolejnych latach dla cz³onków kongresu 
--		(B£¥D: Brak poprawnych wartoœci cohort_retained dla zakresu pomiêdzy kadencjami)
SELECT
	-- Obliczamy przedzia³ miêdzy ka¿d¹ wartoœci¹ z pola term_start, a wartoœci¹ pola first_term dla ka¿dego cz³onka kongresu
	-- Z uzyskanych przedzia³ów pobieramy tylko liczbê lat
	DATEDIFF(year, lt2.first_term, lt3.term_start) AS [period],
	
	-- Obliczamy iloœæ cz³onków kongersu w danym okresie
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

GROUP BY
	DATEDIFF(year, lt2.first_term, lt3.term_start)


--OUTPUT:
--		0		12518
--		1		148
--		2		7120
--		3		124
--		4		4925
--		5		109
--		6		4008
--		7		104
--		8		2894
--		9		88
--		10	2356




--	1. Nastêpnie musimy obliczyæ ³¹czn¹ wielkoœæ kohorty i zapisaæ j¹ w ka¿dym wierszu, aby uzyskaæ %
--		(B£¥D: Brak poprawnych wartoœci cohort_retained dla zakresu pomiêdzy kadencjami)
SELECT
	lt4.period,

	-- Pierwsza wartoœæ cohort_retained z okna posortowanego po period (czyli wartoœæ dla period 0)
	FIRST_VALUE(lt4.cohort_retained) OVER (
		ORDER BY lt4.period
	) AS [cohort_size],

	lt4.cohort_retained,

	-- % utrzymania w danym okresie
	CAST(cohort_retained AS float) / 
	FIRST_VALUE(lt4.cohort_retained) OVER (
		ORDER BY lt4.period
	) AS [pct_retained]

FROM
	(
		-- Tabela z okresami i iloœci¹ cz³onków kongresu w danym okresie
		SELECT
			DATEDIFF(year, lt2.first_term, lt3.term_start) AS [period],
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

		GROUP BY
			DATEDIFF(year, lt2.first_term, lt3.term_start)
	) lt4


--OUTPUT:
--		0		12518		12518		1
--		1		12518		148			0.0118229749161208
--		2		12518		7120		0.568780955424189
--		3		12518		124			0.00990573574053363
--		4		12518		4925		0.393433455823614
--		5		12518		109			0.00870746125579166
--		6		12518		4008		0.320178942323055
--		7		12518		104			0.00830803642754434
--		8		12518		2894		0.231187090589551
--		9		12518		88			0.0070298769771529
--		10	12518		2356		0.188208979070139





-- 2. Tworzymy rekordy dla danych z zakresów pomiêdzy datami, które nie zosta³y uwzglêdnione
SELECT
	lt2.id_bioguide,
	lt2.first_term,
	lt3.term_start,
	lt3.term_end,
	y.year_date,

	-- Kolumna z okresami dla wszystkich lat kadencji dla ka¿dego z cz³onków kongresu
	DATEDIFF(year, lt2.first_term, y.year_date) AS [period]

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

	-- Tabela z latami z zakresy 1770-2020 (w formacie 'YYYY-12-31')
	LEFT JOIN YearlyCalendar y
		ON y.year_date BETWEEN lt3.term_start AND lt3.term_end
	

-- OUTPUT:
--		A000001		1951-01-03	1951-01-03	1953-01-03	1951-12-31	0
--		A000001		1951-01-03	1951-01-03	1953-01-03	1952-12-31	1
--		A000002		1947-01-03	1947-01-03	1949-01-03	1947-12-31	0
--		A000002		1947-01-03	1947-01-03	1949-01-03	1948-12-31	1
--		A000002		1947-01-03	1949-01-03	1951-01-03	1949-12-31	2
--		A000002		1947-01-03	1949-01-03	1951-01-03	1950-12-31	3
--		A000002		1947-01-03	1967-01-10	1969-01-03	1967-12-31	20
--		A000002		1947-01-03	1967-01-10	1969-01-03	1968-12-31	21
--		A000002		1947-01-03	1969-01-03	1971-01-03	1969-12-31	22
--		A000002		1947-01-03	1969-01-03	1971-01-03	1970-12-31	23
--		A000002		1947-01-03	1971-01-21	1973-01-03	1971-12-31	24
--		A000002		1947-01-03	1971-01-21	1973-01-03	1972-12-31	25
--		A000002		1947-01-03	1951-01-03	1953-01-03	1951-12-31	4
--		A000002		1947-01-03	1951-01-03	1953-01-03	1952-12-31	5
--		A000002		1947-01-03	1953-01-03	1955-01-03	1953-12-31	6
--		A000002		1947-01-03	1953-01-03	1955-01-03	1954-12-31	7
--		A000002		1947-01-03	1955-01-05	1957-01-03	1955-12-31	8
--		A000002		1947-01-03	1955-01-05	1957-01-03	1956-12-31	9
--		A000002		1947-01-03	1957-01-03	1959-01-03	1957-12-31	10
--		A000002		1947-01-03	1957-01-03	1959-01-03	1958-12-31	11
--		A000002		1947-01-03	1959-01-07	1961-01-03	1959-12-31	12
--		A000002		1947-01-03	1959-01-07	1961-01-03	1960-12-31	13
--		A000002		1947-01-03	1961-01-03	1963-01-03	1961-12-31	14
--		A000002		1947-01-03	1961-01-03	1963-01-03	1962-12-31	15
--		A000002		1947-01-03	1963-01-09	1965-01-03	1963-12-31	16
--		A000002		1947-01-03	1963-01-09	1965-01-03	1964-12-31	17
--		A000002		1947-01-03	1965-01-04	1967-01-03	1965-12-31	18
--		A000002		1947-01-03	1965-01-04	1967-01-03	1966-12-31	19


-- 2. Nastêpnie obliczamy iloœci cz³onków w poszczególnych okresach
SELECT
	-- Do uwzglêdnienia kadencji osób, które zaczê³y i skoñczy³y w tym samym roku wykorzystujemy COALESCE (zmiana nullów)
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

GROUP BY
	COALESCE(DATEDIFF(year, lt2.first_term, y.year_date), 0)


-- OUTPUT:
--		period	cohort_retained
--		0				12518
--		1				12328
--		2				8162
--		3				8065
--		4				5853
--		5				5786
--		6				4360
--		7				4338
--		8				3513
--		9				3476
--		10			2935


-- 2. Ostatni krok polega na obliczeniu wartoœci cohort_size i pct_retained	#!
SELECT
	lt4.period,
	
	-- wartoœæ cohort_retained w okresie 0
	FIRST_VALUE(lt4.cohort_retained) OVER (
		ORDER BY lt4.period
	) AS [cohort_size],

	lt4.cohort_retained,

	-- wartoœæ % w danym okresie wzglêdem wartoœci z okresu 0
	CAST(lt4.cohort_retained AS float) /
	FIRST_VALUE(lt4.cohort_retained) OVER (
		ORDER BY lt4.period
	) AS [pct_retained]

FROM
	(
		-- Tabela z iloœci¹ cz³onków kongresu z podzia³em na okresy
		SELECT
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

		GROUP BY
			COALESCE(DATEDIFF(year, lt2.first_term, y.year_date), 0)
	) lt4


-- OUTPUT:
--period	cohort_size		cohort_retained		pct_retained
--0				12518					12518							1
--1				12518					12328							0.984821856526602
--2				12518					8162							0.652021089630931
--3				12518					8065							0.644272247962933
--4				12518					5853							0.467566703946317
--5				12518					5786							0.462214411247803
--6				12518					4360							0.348298450231666
--7				12518					4338							0.346540980987378
--8				12518					3513							0.28063588432657
--9				12518					3476							0.27768014059754
--10			12518					2935							0.234462374181179
--11			12518					2891							0.230947435692603
--12			12518					2354							0.18804920913884
--13			12518					2326							0.185812430100655
--14			12518					1977							0.157932577088992
--15			12518					1958							0.156414762741652