USE AdvancedTechniques
GO



--	-----[   PORÓWNYWANIE KOMPONENTÓW   ]-----


--	1. Trend sprzeda¿y rocznej z rozbiciem na rodzaj biznesu
SELECT
	-- grupujemy obiekty po roku sprzeda¿y
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


--	2. Trend sprzeda¿y rocznej dla dwóch biznesów - sumy w osobnych kolumnach
SELECT
	-- grupujemy obiekty po roku sprzeda¿y
	DATEPART(year, r.sales_month) AS [sales_year],

	-- sprzeda¿ sklepów z odzie¿¹ damsk¹
	SUM(
		CASE
			WHEN r.kind_of_business = 'Women''s clothing stores' THEN r.sales
		END
	) AS [womens_sales],

	-- sprzeda¿ sklepów z odzie¿¹ mêsk¹
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


-- 2. Obliczanie ró¿nicy procentowej miêdzy komponentami 
SELECT
	r2.sales_year,

	-- % ró¿nica miêdzy sprzeda¿¹ odzie¿y damskiej i odzie¿y mêskiej
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



--	-----[   OBLICZANIE PROCENTÓW Z CA£OŒCI   ]-----


-- 1. Tworzymy tabele ze rozbiciem sprzeda¿y na damsk¹ i mêsk¹ w danym roku oraz z ich sum¹
SELECT
	r.sales_month,
	r.kind_of_business,
	r.sales,

	-- Je¿eli wczesniej u¿yliœmy r.sales w SELECT, to nie mo¿emy teraz obliczyæ SUM(r.sales)
	-- Musimy stworzyæ osobn¹ tabelê z t¹ wartoœci¹, aby wartoœæ sales w klauzuli GROUP BY nie by³a w funkcji SUM
	SUM(r2.sales) AS [total_sales]
FROM
	us_retail_sales r
	
	-- JOIN niezbêdny do obliczenia SUM(sales)
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


-- 1. Wykorzystuj¹c poprzedni¹ tabelê obliczamy % z ca³oœci dla danego komponentu
SELECT
	r3.sales_month,
	r3.kind_of_business,

	-- % sprzeda¿y w danym roku wzglêdem pozosta³ych komponentów
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


-- 2. Obliczanie % z ca³oœci za pomoc¹ funkcji okna oraz klauzuli PARTITION BY (dane z pkt 1)	#!
SELECT
	r.sales_month,
	r.kind_of_business,
	r.sales,

	-- Wykorzystuj¹c PARTITION BY r.sales_month tworzymy okna dla ka¿dego miesi¹ca
	-- W ten sposób mo¿emy obliczyæ sumy sprzeda¿y wszystkich komponentów z podzia³em na miesi¹ce
	SUM(r.sales) OVER (
		PARTITION BY r.sales_month
	) AS [total_sales],

	-- Obliczamy wartoœæ % sprzeda¿y komponentu w danym miesi¹cu
	-- Tu równie¿ niezbêdna jest klauzula PARTITION BY, poniewa¿ wykorzystujemy funkcjê SUM
	r.sales * 100 / SUM(r.sales) OVER (
		PARTITION BY r.sales_month
	) AS [pct_total]

FROM
	us_retail_sales r
WHERE
	r.kind_of_business IN ('Women''s clothing stores',
		'Men''s clothing stores')


-- 2. Obliczanie % sprzeda¿y w konkretnym roku za pomoc¹ okna	#!
SELECT
	r.sales_month,
	r.kind_of_business,
	r.sales,

	-- Suma sprzeda¿y komponentów w danym roku
	SUM(r.sales) OVER (
		PARTITION BY DATEPART(year, r.sales_month)
	) AS [total_sales],

	-- Obliczamy wartoœæ % sprzeda¿y komponentu w danym miesi¹cu
	-- Tu równie¿ niezbêdna jest klauzula PARTITION BY, poniewa¿ wykorzystujemy funkcjê SUM
	r.sales * 100 / SUM(r.sales) OVER (
		PARTITION BY DATEPART(year, r.sales_month)
	) AS [pct_total]

FROM
	us_retail_sales r
WHERE
	r.kind_of_business IN ('Women''s clothing stores',
		'Men''s clothing stores')
