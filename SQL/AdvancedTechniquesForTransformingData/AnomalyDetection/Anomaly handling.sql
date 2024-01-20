USE AdvancedTechniques
GO



--	-----[   USUWANIE DANYCH   ]-----


--	1. Filtrowanie danych z anomaliami, które mog¹ wp³yn¹æ negatywnie na wyniki
SELECT
	e.time
	, e.mag
	, e.type
FROM
	earthquakes e
WHERE
	e.mag NOT IN (-9, -9.99)


--	2. Je¿eli mamy zamiar wykluczyæ czêœæ danych ze wzglêdu na wyniki,
--			to warto najpierw sprawdziæ jaki maj¹ one wp³yw na wartoœci wyników
--			( w tym przypadku jest nieznaczny wp³yw i mo¿e nie byæ potrzebne filtrowanie danych)
SELECT
	AVG(e.mag) AS [avg_mag]
	, AVG(
		CASE
			WHEN e.mag > -9 THEN e.mag
		END
	) AS [avg_mag_adjusted]
FROM
	earthquakes e


--		OUTPUT:
--	avg_mag						avg_mag_adjusted
--	1.62510260811314	1.62732365796175



--	-----[   ZASTÊPOWANIE INNYMI WARTOŒCIAMI   ]-----


--	1. Je¿eli w zbiorze wystêpuj¹ nieodpowiednie wartoœci, które chcemy zast¹piæ
--			to mo¿emy zrobiæ to za pomoc¹ COALESCE lub CASE
SELECT

	CASE
		WHEN e.type = 'earthquake'
			THEN e.type
		ELSE
			'Other'
	END AS [event_type]

	, COUNT(*) AS [count]

FROM
	earthquakes e
GROUP BY
	CASE
		WHEN e.type = 'earthquake'
			THEN e.type
		ELSE
			'Other'
	END


--	2. W przypadku odstaj¹cych wartoœci liczbowych mo¿emy wykorzystaæ Winsoryzacjê
--			Winsoryzacja polega na zastêpowaniu wartoœæi odstaj¹cych wartoœciami odpowiadaj¹cymi
--			okreœlonemy percentylowi. Przyk³adowo wartoœci powy¿ej percentyla 95% 
--			s¹ zastêpowane wartoœciami odpowiadaj¹cymi temu percentylowi
SELECT
	e3.time
	, e3.place
	, e3.mag

	, CASE
		WHEN e3.mag > e2.percentile_95
			THEN e2.percentile_95
		WHEN e3.mag < e2.percentile_05
			THEN e2.percentile_05
	END AS [mag_winsorized]

FROM
	earthquakes e3

	INNER JOIN
	(
		SELECT

			PERCENTILE_CONT(0.95) WITHIN GROUP (
				ORDER BY e.mag
			) OVER (
				PARTITION BY e.place
			) AS [percentile_95]

			,	PERCENTILE_CONT(0.05) WITHIN GROUP (
				ORDER BY e.mag
			) OVER (
				PARTITION BY e.place
			) AS [percentile_05]

		FROM
			earthquakes e
	) e2
		ON 1 = 1
GROUP BY
	e3.time
	, e3.place
	, e3.mag

--	-----[   SKALOWANIE   ]-----


--	1. Mo¿emy wykorzystaæ skalowanie logarytmiczne, które jest szczególnie przydatne
--			w sytuacji, gdy wystêpuje du¿y rozrzut wartoœci dodatnich, 
--			a wzorce, których wykrycie jest istotne, wystêpuj¹ w zakresie niskich wartoœci
SELECT
	ROUND(e.depth, 1) AS [depth]
	, LOG(ROUND(e.depth, 1)) AS [log_depth]
	, COUNT(*) AS [earthquakes]
FROM
	earthquakes e
WHERE
	e.depth >= 0.05
GROUP BY
	ROUND(e.depth, 1)
	, LOG(ROUND(e.depth, 1))
ORDER BY 
	ROUND(e.depth, 1)


--		OUTPUT:
--	depth		log_depth						earthquakes
--	0.1			-2.30258509299405		7622
--	0.2			-1.6094379124341		6548
--	0.3			-1.20397280432594		7657
--	0.4			-0.916290731874155	7211
--	0.5			-0.693147180559945	7445
--	0.6			-0.510825623765991	7691
