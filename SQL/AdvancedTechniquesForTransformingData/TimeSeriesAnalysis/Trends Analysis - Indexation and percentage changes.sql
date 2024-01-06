USE AdvancedTechniques
GO



--	-----[   STOSOWANIE INDEKSACJI - ZMIANY WZGL�DEM PUNKTU W CZASIE   ]-----


--	1. Indeksacja - obliczanie r�nicy procentowej wzgl�dem pierwszego roku	#!
SELECT
	r2.sales_year,
	r2.sales,

	-- Indeksem w tym przypadku jest pierwsza warto�� sales (czyli z pierwszego roku)
	-- Uzyskujemy j� dzi�ki funkcji FIRST_VALUE, OVER oraz klauzuli ORDER BY
	-- Nast�pnie obliczamy zmian� procentow� wzgl�dem tej warto�ci dla kolejnych lat
	(r2.sales / FIRST_VALUE(r2.sales) OVER (
		ORDER BY r2.sales_year
	) - 1) * 100 AS [pct_from_index]

FROM
	(
		-- Tabela z sum� sprzeda�y z podzia�em na rok dla odzie�y damskiej
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


--	2. Obliczanie r�nicy procentowej wzgl�dem pierwszego roku z podzia�em na rodzaj biznesu	#!
SELECT
	r2.sales_year,
	r2.sales,
	r2.kind_of_business,

	-- Gdy obliczamy indeks z podzia�em na rodzaj biznesu, to musimy dodatkowo wykorzysta� klauzul� PARTITION BY
	(r2.sales / FIRST_VALUE(r2.sales) OVER (
		PARTITION BY r2.kind_of_business ORDER BY r2.sales_year
	) - 1) * 100 AS [pct_from_index]

FROM
	(
			-- Tabela z sum� sprzeda�y z podzia�em na rok dla odzie�y damskiej i m�skiej
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



--	-----[   OBLICZENIA ZA POMOC� OKIEN PRZESUWNYCH   ]-----
--	np. LTM (last twelve months), TTM (trailing twelve months), YTD (year-to-date)


-- 1. Tworzymy tabel� z sprzeda�� w danym miesi�cu oraz warto�ciami sprzeda�y dla poprzednich 11 miesi�cy
SELECT
	r.sales_month,
	r.sales,
	r2.sales_month AS [rolling_sales_month],
	r2.sales AS [rolling_sales]
FROM
	us_retail_sales r

	-- �eby otrzyma� dane z poprzednich 12 miesi�cy wykorzystujem INNER JOIN
	INNER JOIN us_retail_sales r2
		ON r.kind_of_business = r2.kind_of_business
		-- Ustawiamy zakres dat na ostatnich 12 miesi�cy -	DATEADD(month, -11, r.sales_month)
		AND r2.sales_month BETWEEN DATEADD(month, -11, r.sales_month) AND r.sales_month
		AND r2.kind_of_business = 'Women''s clothing stores'

WHERE
	r.kind_of_business = 'Women''s clothing stores'
	-- Ustawiamy grudzie� jako miesi�c od kt�rego zostanie utworzony interwa� -11 miesi�cy
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


-- 1. Nast�pnie tworzymy agregacj� (w tym przypadku AVG)
--		Uwzgl�dniamy r�wnie� liczb� rekord�w zwr�conych z tabeli, aby zweryfikowa� czy ka�dy wiersz to �rednia 12 punkt�w danych
--		Przefiltrowanie obu tabel za pomoc� r.kind_of_business = 'Women''s clothing stores' przyspiesza wykonanie zapytania
SELECT
	r.sales_month,
	r.sales,

	-- �rednia ostatni 12 miesi�cy
	AVG(r2.sales) AS [moving_sales],

	-- liczba rekord�w (weryfikacja czy jest ich 12)
	COUNT(r2.sales) AS [records_count]

FROM
	us_retail_sales r

	-- �eby otrzyma� dane z poprzednich 12 miesi�cy wykorzystujem INNER JOIN
	INNER JOIN us_retail_sales r2
		ON r.kind_of_business = r2.kind_of_business
		-- Ustawiamy zakres dat na ostatnich 12 miesi�cy -	DATEADD(month, -11, r.sales_month)
		AND r2.sales_month BETWEEN DATEADD(month, -11, r.sales_month) AND r.sales_month
		AND r2.kind_of_business = 'Women''s clothing stores'

WHERE
	r.kind_of_business = 'Women''s clothing stores'
	-- rok rozpocz�cia oblicze�
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