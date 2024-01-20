USE AdvancedTechniques
GO



--	-----[   ANOMALIE WARTO�CI   ]-----


--	1. Wyszukiwanie anomalii warto�ci na podstawie liczby wyst�pie� z grupowaniem
SELECT

	CASE
		WHEN e.place LIKE '% of %'
			THEN dbo.fnSplitString(e.place, ' of ', 2)
		ELSE
			e.place
	END AS [place_name]

	, COUNT(*) AS [count]

FROM
	earthquakes e
WHERE
	e.depth > 600
GROUP BY

	CASE
		WHEN e.place LIKE '% of %'
			THEN dbo.fnSplitString(e.place, ' of ', 2)
		ELSE
			e.place
	END

ORDER BY
	[count] DESC


--		OUTPUT:
--	place_name					count
--	Ndoi Island, Fiji		487
--	Fiji region					186
--	Lambasa, Fiji				140
--	the Fiji Islands		63
--	Sola, Vanuatu				50


--	2. Odnajdywanie r�nic w nazwie 
SELECT
	e.type
	, LOWER(e.type)

	, CASE
			WHEN e.type = LOWER(e.type) THEN 'true'
			ELSE 'false'
	END AS [flag]

	, COUNT(*) AS [records]
FROM
	earthquakes e
GROUP BY
	e.type
	, LOWER(e.type)

	, CASE
			WHEN e.type = LOWER(e.type) THEN 'true'
			ELSE 'false'
		END

ORDER BY
	LOWER(e.type)
	, [flag] DESC



--	-----[   ANOMALIE LICZBY WYST�PIE�   ]-----


--	1. Badanie liczby wyst�pie� wykorzystuj�� grupowanie 
--			(jeden rodzaj rekord�w mo�e mie� wi�kszy wp�yw na skok warto�ci w danym okresie)
SELECT
	DATEFROMPARTS(
		YEAR(e.time)
		, MONTH(e.time)
		, 1
	) AS [earthquake_month]
	, e.status
	, COUNT(*) AS [earthquakes]

FROM
	earthquakes e

GROUP BY
	DATEFROMPARTS(
		YEAR(e.time)
		, MONTH(e.time)
		, 1
	) 
	, e.status

ORDER BY
	DATEFROMPARTS(
		YEAR(e.time)
		, MONTH(e.time)
		, 1
	) 

--		OUTPUT:
--	earthquake_month	status			earthquakes
--	2010-01-01				automatic		610
--	2010-01-01				reviewed		9012
--	2010-02-01				automatic		684
--	2010-02-01				reviewed		6957
--	2010-03-01				automatic		821
--	2010-03-01				reviewed		6886
--	2010-04-01				automatic		726
--	2010-04-01				reviewed		18619



--	-----[   ANOMALIE W POSTACI BRAKU DANYCH   ]-----


--	1. Stworzenie funkcji odpowiadaj�cej za zmian� pierwszych liter s��w na wielkie
GO

ALTER FUNCTION dbo.fnInitCap ( @InputString varchar(4000) ) 
RETURNS VARCHAR(4000)
AS
BEGIN

DECLARE @Index          INT
DECLARE @Char           CHAR(1)
DECLARE @PrevChar       CHAR(1)
DECLARE @OutputString   VARCHAR(255)

SET @OutputString = LOWER(@InputString)
SET @Index = 1

WHILE @Index <= LEN(@InputString)
BEGIN
    SET @Char     = SUBSTRING(@InputString, @Index, 1)
    SET @PrevChar = CASE WHEN @Index = 1 THEN ' '
                         ELSE SUBSTRING(@InputString, @Index - 1, 1)
                    END

    IF @PrevChar IN (' ', ';', ':', '!', '?', ',', '.', '_', '-', '/', '&', '''', '(')
    BEGIN
        IF @PrevChar != '''' OR UPPER(@Char) != 'S'
            SET @OutputString = STUFF(@OutputString, @Index, 1, UPPER(@Char))
    END

    SET @Index = @Index + 1
END

RETURN @OutputString

END
GO


--	2. Zapytanie do sprawdzenia odst�p�w mi�dzy du�ymi trz�sieniami ziemi i czasu od ostatniego trz�sienia
SELECT

	e3.place

	-- ilo�� minionych dni od ostatniego trz�sienia (2020-12-31 jako tera�niejsza data)
	, DATEDIFF(
		day
		,	e3.latest
		, '2020-12-31'
	) AS [days_since_latest]

	, COUNT(*) AS [earthquakes]
	, AVG(e3.gap) AS [avg_gap]
	, MAX(e3.gap) AS [max_gap]


FROM
	(
		-- Zapytanie z wykorzstaniem funkcji LEAD, aby znale�� czas nast�pnego trz�sienia ziemi
		--	dla ka�dej kombinacji miejsca i czasu, 
		--	a tak�e do wyznaczenia przedzia�u czasu mi�dzy ka�d� par� kolejnych trz�sie�
		SELECT

			e2.place

			, LEAD(e2.time) OVER (
				PARTITION BY e2.place
				ORDER BY e2.time
			) AS [next_time]

			, DATEDIFF(
				day
				, e2.time
				, LEAD(e2.time) OVER (
					PARTITION BY e2.place
					ORDER BY e2.time
				)
			) AS [gap]

			, MAX(e2.time) OVER (
				PARTITION BY e2.place
			) AS [latest]

		FROM
			(
				-- Zapytanie parsuj�ce i oczyszczaj�ce pole place oraz 
				-- zwracaj�ce wi�ksze obszary lub pa�stwa z czasem ka�dego trz�sienia ziemi
				SELECT
	
					REPLACE(
						dbo.fnInitCap(
							CASE
								WHEN e.place LIKE '%, [A-Z]'
									THEN dbo.fnSplitString(e.place, ', ', 2)
								WHEN e.place LIKE '% of %'
									THEN dbo.fnSplitString(e.place, ' of ', 2)
								ELSE
									e.place
							END
						)
						, 'Region', ''
					) AS [place]

					, e.time

				FROM
					earthquakes e
				WHERE
					e.mag > 5
			) e2
	) e3

GROUP BY
	e3.place

	, DATEDIFF(
		day
		,	e3.latest
		, '2020-12-31'
	) 

--		OUTPUT:
--	place											days_since_latest		earthquakes		avg_gap		max_gap
--	Sarangani, Philippines		2										45						60				247
--	Owen Fracture Zone 				3										11						384				1732
--	Southeast Indian Ridge		3										35						117				552
--	Tomohon, Indonesia				3										3							30				57

