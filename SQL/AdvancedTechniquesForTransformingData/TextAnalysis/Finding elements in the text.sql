USE AdvancedTechniques
GO



--	-----[  ZNAJDOWANIE ELEMENTÓW W WIÊKSZYCH BLOKACH TEKSTU   ]-----


--	1. Znajdowanie s³ów za pomoc¹ operatora LIKE i zliczanie wyst¹pieñ
SELECT

	COUNT(
		CASE
			WHEN u.description LIKE '%south%' THEN 1
		END
	) AS [south],

	COUNT(
		CASE
			WHEN u.description LIKE '%north%' THEN 1
		END
	) AS [north],

	COUNT(
		CASE
			WHEN u.description LIKE '%east%' THEN 1
		END
	) AS [east],

	COUNT(
		CASE
			WHEN u.description LIKE '%west%' THEN 1
		END
	) AS [west]

FROM
	ufo u



--	2. Dopasowywanie za pomoc¹ operatorów IN i NOT IN
SELECT
	u3.first_word_type,
	COUNT(*) AS [count]
FROM
	(
		SELECT
			CASE
				WHEN LOWER(u2.first_word) IN ('red', 'orange', 'yellow', 'green', 'blue', 'purple', 'white')
					THEN 'Color'
				WHEN LOWER(u2.first_word) IN ('round', 'circular', 'oval', 'cigar')
					THEN 'Shape'
				WHEN LOWER(u2.first_word) LIKE 'triang%'
					THEN 'Shape'
				WHEN LOWER(u2.first_word) LIKE 'flash%'
					THEN 'Motion'
				WHEN LOWER(u2.first_word) LIKE 'hover%'
					THEN 'Motion'
				WHEN LOWER(u2.first_word) LIKE 'pulsat%'
					THEN 'Motion'
				ELSE
					'Other'
			END AS [first_word_type]
		FROM
			(
				SELECT
					dbo.fnSplitString(u.description, ' ', 1) AS [first_word]
				FROM
					ufo u
			) u2
	) u3
GROUP BY
	u3.first_word_type
ORDER BY
	count DESC



--	3. Wildcard '_' - pojedynczy znak
SELECT

	CASE	-- true
		WHEN 'To dane na temat UFO' LIKE '_o dane%'
			THEN 'true'
		ELSE
			'false'
	END AS [comparison_1],

	CASE	-- false
		WHEN 'To dane na temat UFO' LIKE '_To dane%'
			THEN 'true'
		ELSE
			'false'
	END AS [comparison_2]


--	4. Wildcard '[]' - okreœlony zestaw znaków
SELECT

	CASE	-- true
		WHEN 'To dane na temat UFO' LIKE '[Tt]o dane%'
			THEN 'true'
		ELSE
			'false'
	END AS [comparison_1],

	CASE	-- true
		WHEN 'To dane na temat UFO' LIKE '[t]o dane%'
			THEN 'true'
		ELSE
			'false'
	END AS [comparison_2]


--	5. Znajdowanie wzorca odnoœnie œwiate³ (liczba oraz s³owo light)
SELECT 
	LEFT(u.description, 50)
FROM 
	ufo u
WHERE 
	LEFT(u.description, 50) LIKE '%[0-9999] light[s ,.]%';


--	6. Znajdowanie wzorca odnoœnie œwiate³ (liczba oraz s³owo light)
SELECT 
	LEFT(u.description, 50)
FROM 
	ufo u
WHERE 
	LEFT(u.description, 50) LIKE '%[0-9999] light[s ,.]%';