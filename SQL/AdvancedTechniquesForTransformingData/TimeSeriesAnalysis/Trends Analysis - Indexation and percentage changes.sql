USE AdvancedTechniques
GO



--	-----[   STOSOWANIE INDEKSACJI - ZMIANY WZGLÊDEM PUNKTU W CZASIE   ]-----


--	1. Indeksacja - obliczanie ró¿nicy procentowej wzglêdem pierwszego roku	#!
SELECT
	r2.sales_year,
	r2.sales,

	-- Indeksem w tym przypadku jest pierwsza wartoœæ sales (czyli z pierwszego roku)
	-- Uzyskujemy j¹ dziêki funkcji FIRST_VALUE, OVER oraz klauzuli ORDER BY
	-- Nastêpnie obliczamy zmianê procentow¹ wzglêdem tej wartoœci dla kolejnych lat
	(r2.sales / FIRST_VALUE(r2.sales) OVER (
		ORDER BY r2.sales_year
	) - 1) * 100 AS [pct_from_index]

FROM
	(
		-- Tabela z sum¹ sprzeda¿y z podzia³em na rok dla odzie¿y damskiej
		SELECT
			DATEPART(year, r.sales_month) AS [sales_year],
			SUM(r.sales) AS [sales]
		FROM
			us_retail_sales r
		WHERE
			r.kind_of_business = 'Women''s clothing stores'
		GROUP BY
			DATEPART(year, r.sales_month)
	) r2


--	2. Obliczanie ró¿nicy procentowej wzglêdem pierwszego roku z podzia³em na rodzaj biznesu	#!
SELECT
	r2.sales_year,
	r2.sales,
	r2.kind_of_business,

	-- Gdy obliczamy indeks z podzia³em na rodzaj biznesu, to musimy dodatkowo wykorzystaæ klauzulê PARTITION BY
	(r2.sales / FIRST_VALUE(r2.sales) OVER (
		PARTITION BY r2.kind_of_business ORDER BY r2.sales_year
	) - 1) * 100 AS [pct_from_index]

FROM
	(
			-- Tabela z sum¹ sprzeda¿y z podzia³em na rok dla odzie¿y damskiej i mêskiej
			SELECT
				DATEPART(year, r.sales_month) AS [sales_year],
				r.kind_of_business,
				SUM(r.sales) AS [sales]
			FROM
				us_retail_sales r
			WHERE
				r.kind_of_business IN ('Women''s clothing stores',
					'Men''s clothing stores')
				AND r.sales_month <= '2019-12-01'
			GROUP BY
				DATEPART(year, r.sales_month),
				r.kind_of_business
	) r2
ORDER BY
	r2.sales_year



--	-----[   OBLICZENIA ZA POMOC¥ OKIEN PRZESUWNYCH   ]-----
--	np. LTM (last twelve months), TTM (trailing twelve months), YTD (year-to-date)


-- 1. Tworzymy tabelê z sprzeda¿¹ w danym miesi¹cu oraz wartoœciami sprzeda¿y dla poprzednich 11 miesiêcy
SELECT
	r.sales_month,
	r.sales,
	r2.sales_month AS [rolling_sales_month],
	r2.sales AS [rolling_sales]
FROM
	us_retail_sales r

	-- ¯eby otrzymaæ dane z poprzednich 12 miesiêcy wykorzystujem INNER JOIN
	INNER JOIN us_retail_sales r2
		ON r.kind_of_business = r2.kind_of_business
		-- Ustawiamy zakres dat na ostatnich 12 miesiêcy -	DATEADD(month, -11, r.sales_month)
		AND r2.sales_month BETWEEN DATEADD(month, -11, r.sales_month) AND r.sales_month
		AND r2.kind_of_business = 'Women''s clothing stores'

WHERE
	r.kind_of_business = 'Women''s clothing stores'
	-- Ustawiamy grudzieñ jako miesi¹c od którego zostanie utworzony interwa³ -11 miesiêcy
	AND r.sales_month = '2019-12-01'


-- OUTPUT:
--		r.mnth			r.sales					r2.mnth			r2.sales	
--		2019-12-01	4496.0000000000	2019-01-01	2511.0000000000
--		2019-12-01	4496.0000000000	2019-02-01	2680.0000000000
--		2019-12-01	4496.0000000000	2019-03-01	3585.0000000000
--		2019-12-01	4496.0000000000	2019-04-01	3604.0000000000
--		2019-12-01	4496.0000000000	2019-05-01	3807.0000000000
--		2019-12-01	4496.0000000000	2019-06-01	3272.0000000000
--		2019-12-01	4496.0000000000	2019-07-01	3261.0000000000
--		2019-12-01	4496.0000000000	2019-08-01	3325.0000000000
--		2019-12-01	4496.0000000000	2019-09-01	3080.0000000000
--		2019-12-01	4496.0000000000	2019-10-01	3390.0000000000
--		2019-12-01	4496.0000000000	2019-11-01	3850.0000000000
--		2019-12-01	4496.0000000000	2019-12-01	4496.0000000000


-- 1. Nastêpnie tworzymy agregacjê (w tym przypadku AVG)
--		Uwzglêdniamy równie¿ liczbê rekordów zwróconych z tabeli, aby zweryfikowaæ czy ka¿dy wiersz to œrednia 12 punktów danych
--		Przefiltrowanie obu tabel za pomoc¹ r.kind_of_business = 'Women''s clothing stores' przyspiesza wykonanie zapytania
SELECT
	r.sales_month,
	r.sales,

	-- œrednia ostatni 12 miesiêcy
	AVG(r2.sales) AS [moving_sales],

	-- liczba rekordów (weryfikacja czy jest ich 12)
	COUNT(r2.sales) AS [records_count]

FROM
	us_retail_sales r

	-- ¯eby otrzymaæ dane z poprzednich 12 miesiêcy wykorzystujem INNER JOIN
	INNER JOIN us_retail_sales r2
		ON r.kind_of_business = r2.kind_of_business
		-- Ustawiamy zakres dat na ostatnich 12 miesiêcy -	DATEADD(month, -11, r.sales_month)
		AND r2.sales_month BETWEEN DATEADD(month, -11, r.sales_month) AND r.sales_month
		AND r2.kind_of_business = 'Women''s clothing stores'

WHERE
	r.kind_of_business = 'Women''s clothing stores'
	-- rok rozpoczêcia obliczeñ
	AND r.sales_month >= '1993-01-01'
GROUP BY
	r.sales_month,
	r.sales
ORDER BY
	r.sales_month


-- 2. Wykorzystanie funkcji ramki do stworzenia okna (preceding rows / following rows)	#!
SELECT
	r.sales_month,

	-- ORDER BY r.sales_month ROWS BETWEEN 11 PRECEDING AND CURRENT ROW		- funkcja ramki dla zakresu ostatnich 12 wierszy
	AVG(r.sales) OVER (
		ORDER BY r.sales_month ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
	) AS [moving_avg],

	COUNT(r.sales) OVER (
		ORDER BY r.sales_month ROWS BETWEEN 11 PRECEDING AND CURRENT ROW
	) AS [records_count]

FROM
	us_retail_sales r
WHERE
	r.kind_of_business = 'Women''s clothing stores'


-- OUTPUT:
--		r.mnth			r.avg						r.rec_count
--		1992-01-01	1873.0000000000	1
--		1992-02-01	1932.0000000000	2
--		1992-03-01	2089.0000000000	3
--		1992-04-01	2233.0000000000	4
--		1992-05-01	2336.8000000000	5
--		1992-06-01	2351.3333333333	6
--		1992-07-01	2354.4285714285	7
--		1992-08-01	2392.2500000000	8
--		1992-09-01	2410.8888888888	9
--		1992-10-01	2445.3000000000	10
--		1992-11-01	2490.8181818181	11
--		1992-12-01	2651.2500000000	12
--		1993-01-01	2672.0833333333	12
--		1993-02-01	2673.2500000000	12
--		1993-03-01	2676.5000000000	12
--		1993-04-01	2684.5833333333	12