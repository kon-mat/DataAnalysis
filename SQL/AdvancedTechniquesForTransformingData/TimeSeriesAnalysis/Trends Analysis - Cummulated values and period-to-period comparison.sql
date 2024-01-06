USE AdvancedTechniques
GO



--	-----[   OBLICZANIE WARTOŒÆI SKUMULOWANYCH   ]-----


--	1. Tabela ze sprzeda¿¹ w danym miesi¹cu oraz sprzeda¿¹ skumulowan¹ w danym roku	#!
SELECT
	r.sales_month,
	r.sales,

	-- Sprzeda¿ skumulowana year-to-date
	SUM(r.sales) OVER (
		PARTITION BY DATEPART(year, r.sales_month) 
		ORDER BY r.sales_month
	) AS [sales_ytd]

FROM
	us_retail_sales r
WHERE
	r.kind_of_business = 'Women''s clothing stores'


--	-----[   PORÓWNYWANIE OKRES DO OKRESU   ]-----
--	np. RDR (rok do roku), MDM (miesi¹c do miesi¹ca)


--	1. Tabela z wartoœciami sprzeda¿y w danym miesi¹cu oraz w miesi¹cu poprzednim
SELECT
	r.kind_of_business,
	r.sales_month,
	r.sales,

	-- Wykorzystujemy funkcjê LAG, która odnosi siê do poprzedniego wiersza
	-- Poniewa¿ grupujemy po rodzaju biznesu, to wykorzystujemy PARTITION BY, by dane by³y spójne
	LAG(r.sales_month) OVER (
		PARTITION BY r.kind_of_business
		ORDER BY r.sales_month
	) AS [prev_month],

	LAG(r.sales) OVER (
		PARTITION BY r.kind_of_business
		ORDER BY r.sales_month
	) AS [prev_month_sales]

FROM
	us_retail_sales r
WHERE
	r.kind_of_business = 'Book stores'


-- OUTPUT:
--		r.type			r.mnth			r.sales					r.prev_mnth	r.prev_mnth_sales
--		Book stores	1992-01-01	790.0000000000	NULL				NULL
--		Book stores	1992-02-01	539.0000000000	1992-01-01	790.0000000000
--		Book stores	1992-03-01	535.0000000000	1992-02-01	539.0000000000
--		Book stores	1992-04-01	523.0000000000	1992-03-01	535.0000000000
--		Book stores	1992-05-01	552.0000000000	1992-04-01	523.0000000000


--	1. Mo¿emy obliczyæ zmianê procentow¹ wzglêdem poprzedniego miesi¹ca	#!
SELECT
	r.kind_of_business,
	r.sales_month,
	r.sales,

	
	(r.sales / LAG(r.sales) OVER (
		PARTITION BY r.kind_of_business
		ORDER BY r.sales_month
	) - 1) * 100
	AS [pct_growth_from_previous]

FROM
	us_retail_sales r
WHERE
	r.kind_of_business = 'Book stores'


-- 2. Porównywanie wartoœci z tych samych miesiêcy w kolejnych latach
SELECT
	r.sales_month,
	r.sales,
	
	-- Grupujemy okno po miesi¹cach (np. dane wy³¹cznie ze stycznia dla kolejnych lat) i wykorzystujemy LAG
	LAG(r.sales_month) OVER (
		PARTITION BY DATEPART(month, r.sales_month)
		ORDER BY r.sales_month
	) AS [prev_year_month],

	LAG(r.sales) OVER (
		PARTITION BY DATEPART(month, r.sales_month)
		ORDER BY r.sales_month
	) AS [prev_year_sales]

FROM
	us_retail_sales r
WHERE
	r.kind_of_business = 'Book stores'


-- OUTPUT:
--		r.mnth			r.sales					r.pr_y_mnt	r.pr_y_sales
--		1992-01-01	790.0000000000	NULL				NULL
--		1993-01-01	998.0000000000	1992-01-01	790.0000000000
--		1994-01-01	1053.0000000000	1993-01-01	998.0000000000
--		1995-01-01	1308.0000000000	1994-01-01	1053.0000000000
--		1996-01-01	1373.0000000000	1995-01-01	1308.0000000000


-- 2. Porównanie sprzeda¿y w latach 1992, 1993, 1994 - rozbicie na miesi¹ce w zakresie rocznym	#!
SELECT
	DATEPART(month, r.sales_month) AS [month_number],

	-- Nazwa miesi¹ca na podstawie daty
	DATENAME(month, r.sales_month) AS [month_name],

	MAX(
		CASE
			WHEN DATEPART(year, r.sales_month) = 1992 THEN r.sales
		END
	) AS [sales_1992],

	MAX(
		CASE
			WHEN DATEPART(year, r.sales_month) = 1993 THEN r.sales
		END
	) AS [sales_1993],

	MAX(
		CASE
			WHEN DATEPART(year, r.sales_month) = 1994 THEN r.sales
		END
	) AS [sales_1994]

FROM
	us_retail_sales r
WHERE
	r.kind_of_business = 'Book stores'
	AND r.sales_month BETWEEN '1992-01-01' AND '1994-12-01'
GROUP BY
	DATEPART(month, r.sales_month),
	DATENAME(month, r.sales_month)
ORDER BY
	DATEPART(month, r.sales_month)


-- OUTPUT:
--		1		January		790.0000000000	998.0000000000	1053.0000000000
--		2		February	539.0000000000	568.0000000000	635.0000000000
--		3		March			535.0000000000	602.0000000000	634.0000000000
--		4		April			523.0000000000	583.0000000000	610.0000000000
--		5		May				552.0000000000	612.0000000000	684.0000000000
--		6		June			589.0000000000	618.0000000000	724.0000000000
--		7		July			592.0000000000	607.0000000000	678.0000000000
--		8		August		894.0000000000	983.0000000000	1154.0000000000
--		9		September	861.0000000000	903.0000000000	1022.0000000000
--		10	October		645.0000000000	669.0000000000	732.0000000000
--		11	November	642.0000000000	692.0000000000	772.0000000000
--		12	December	1165.0000000000	1273.0000000000	1409.0000000000