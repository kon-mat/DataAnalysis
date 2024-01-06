USE AdvancedTechniques
GO



--	-----[   POR�WNYWANIE KOMPONENT�W   ]-----


--	1. Trend sprzeda�y rocznej z rozbiciem na rodzaj biznesu
SELECT
	-- grupujemy obiekty po roku sprzeda�y
	DATEPART(year, r.sales_month) AS [sales_year],
	r.kind_of_business,
	SUM(r.sales) AS [sales]
FROM
	us_retail_sales r
WHERE
	r.kind_of_business IN ('Book stores',
		'Sporting goods stores', 'Hobby, toy, and game stores')
GROUP BY
	DATEPART(year, r.sales_month),
	r.kind_of_business
ORDER BY
	[sales_year]


--	2. Trend sprzeda�y rocznej dla dw�ch biznes�w - sumy w osobnych kolumnach
SELECT
	-- grupujemy obiekty po roku sprzeda�y
	DATEPART(year, r.sales_month) AS [sales_year],

	-- sprzeda� sklep�w z odzie�� damsk�
	SUM(
		CASE
			WHEN r.kind_of_business = 'Women''s clothing stores' THEN r.sales
		END
	) AS [womens_sales],

	-- sprzeda� sklep�w z odzie�� m�sk�
	SUM(
		CASE
			WHEN r.kind_of_business = 'Men''s clothing stores' THEN r.sales
		END
	) AS [mens_sales]

FROM
	us_retail_sales r
WHERE
	r.kind_of_business IN ('Women''s clothing stores',
		'Men''s clothing stores')
GROUP BY
	DATEPART(year, r.sales_month)
ORDER BY
	[sales_year]


-- 2. Obliczanie r�nicy procentowej mi�dzy komponentami 
SELECT
	r2.sales_year,

	-- % r�nica mi�dzy sprzeda�� odzie�y damskiej i odzie�y m�skiej
	(r2.womens_sales / r2.mens_sales - 1) * 100 AS [womens_pct_of_mens]

FROM
	(
		SELECT
			DATEPART(year, r.sales_month) AS [sales_year],

			SUM(
				CASE
					WHEN r.kind_of_business = 'Women''s clothing stores' THEN r.sales
				END
			) AS [womens_sales],

			SUM(
				CASE
					WHEN r.kind_of_business = 'Men''s clothing stores' THEN r.sales
				END
			) AS [mens_sales]

		FROM
			us_retail_sales r
		WHERE
			r.kind_of_business IN ('Women''s clothing stores',
				'Men''s clothing stores')
			AND r.sales_month <= '2019-12-01'
		GROUP BY
			DATEPART(year, r.sales_month)
	) r2



--	-----[   OBLICZANIE PROCENT�W Z CA�O�CI   ]-----


-- 1. Tworzymy tabele ze rozbiciem sprzeda�y na damsk� i m�sk� w danym roku oraz z ich sum�
SELECT
	r.sales_month,
	r.kind_of_business,
	r.sales,

	-- Je�eli wczesniej u�yli�my r.sales w SELECT, to nie mo�emy teraz obliczy� SUM(r.sales)
	-- Musimy stworzy� osobn� tabel� z t� warto�ci�, aby warto�� sales w klauzuli GROUP BY nie by�a w funkcji SUM
	SUM(r2.sales) AS [total_sales]
FROM
	us_retail_sales r
	
	-- JOIN niezb�dny do obliczenia SUM(sales)
	INNER JOIN us_retail_sales r2
		ON r.sales_month = r2.sales_month
		AND r2.kind_of_business IN ('Women''s clothing stores',
			'Men''s clothing stores')

WHERE
	r.kind_of_business IN ('Women''s clothing stores',
		'Men''s clothing stores')
GROUP BY
	r.sales_month,
	r.kind_of_business,
	r.sales
ORDER BY
	r.sales_month


-- 1. Wykorzystuj�c poprzedni� tabel� obliczamy % z ca�o�ci dla danego komponentu
SELECT
	r3.sales_month,
	r3.kind_of_business,

	-- % sprzeda�y w danym roku wzgl�dem pozosta�ych komponent�w
	r3.sales * 100 / r3.total_sales AS [pct_total_sales]
FROM
	(
		SELECT
			r.sales_month,
			r.kind_of_business,
			r.sales,
			SUM(r2.sales) AS [total_sales]
		FROM
			us_retail_sales r
	
			INNER JOIN us_retail_sales r2
				ON r.sales_month = r2.sales_month
				AND r2.kind_of_business IN ('Women''s clothing stores',
					'Men''s clothing stores')

		WHERE
			r.kind_of_business IN ('Women''s clothing stores',
				'Men''s clothing stores')
		GROUP BY
			r.sales_month,
			r.kind_of_business,
			r.sales
	) r3
ORDER BY
	r3.sales_month


-- 2. Obliczanie % z ca�o�ci za pomoc� funkcji okna oraz klauzuli PARTITION BY (dane z pkt 1)	#!
SELECT
	r.sales_month,
	r.kind_of_business,
	r.sales,

	-- Wykorzystuj�c PARTITION BY r.sales_month tworzymy okna dla ka�dego miesi�ca
	-- W ten spos�b mo�emy obliczy� sumy sprzeda�y wszystkich komponent�w z podzia�em na miesi�ce
	SUM(r.sales) OVER (
		PARTITION BY r.sales_month
	) AS [total_sales],

	-- Obliczamy warto�� % sprzeda�y komponentu w danym miesi�cu
	-- Tu r�wnie� niezb�dna jest klauzula PARTITION BY, poniewa� wykorzystujemy funkcj� SUM
	r.sales * 100 / SUM(r.sales) OVER (
		PARTITION BY r.sales_month
	) AS [pct_total]

FROM
	us_retail_sales r
WHERE
	r.kind_of_business IN ('Women''s clothing stores',
		'Men''s clothing stores')


-- 2. Obliczanie % sprzeda�y w konkretnym roku za pomoc� okna	#!
SELECT
	r.sales_month,
	r.kind_of_business,
	r.sales,

	-- Suma sprzeda�y komponent�w w danym roku
	SUM(r.sales) OVER (
		PARTITION BY DATEPART(year, r.sales_month)
	) AS [total_sales],

	-- Obliczamy warto�� % sprzeda�y komponentu w danym miesi�cu
	-- Tu r�wnie� niezb�dna jest klauzula PARTITION BY, poniewa� wykorzystujemy funkcj� SUM
	r.sales * 100 / SUM(r.sales) OVER (
		PARTITION BY DATEPART(year, r.sales_month)
	) AS [pct_total]

FROM
	us_retail_sales r
WHERE
	r.kind_of_business IN ('Women''s clothing stores',
		'Men''s clothing stores')
