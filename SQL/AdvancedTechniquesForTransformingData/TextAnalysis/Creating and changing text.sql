USE AdvancedTechniques
GO



--	-----[  TWORZENIE TEKSTU I ZMIENIANIE JEGO KSZTA£TU   ]-----


--	1. Konkatenacja
SELECT
	CONCAT(u2.shape, ' (shape)') AS [shape],
	CONCAT(u2.reports, ' (reports)') AS [reports]
FROM
	(
		SELECT
			dbo.fnSplitString(
				dbo.fnSplitString(u.sighting_report, 'Duration', 1),
				'Shape: ', 2
			) AS [shape],
			COUNT(*) AS [reports]
		FROM
			ufo u
		GROUP BY
			dbo.fnSplitString(
				dbo.fnSplitString(u.sighting_report, 'Duration', 1),
				'Shape: ', 2
			)
	) u2


--	2. Konkatenacja
SELECT
	CONCAT('There were ',
		u4.reports,
		' reports of ',
		LOWER(u4.shape),
		' ojects. The earliest sighting was ',
		DATEPART(month, u4.earliest),
		' ',
		DATEPART(day, u4.latest),
		' ',
		DATEPART(year, latest)
	)

FROM
	(
		SELECT
			u3.shape,
			MIN(CAST(u3.occurred AS date)) AS [earliest],
			MAX(CAST(u3.occurred AS date)) AS [latest],
			SUM(u3.reports) AS [reports]
		FROM
			(
				SELECT
					u2.occurred,
					u2.shape,
					COUNT(*) AS [reports]
				FROM
					(
						SELECT
							dbo.fnSplitString(
								dbo.fnSplitString(
									dbo.fnSplitString(u.sighting_report, '(Entered', 1),
									'Occurred : ', 2
								),
								'Reported', 1
							) AS [occurred],
							dbo.fnSplitString(
								dbo.fnSplitString(u.sighting_report, 'Duration', 1),
								'Shape: ', 2
							) AS [shape]
						FROM
							ufo u
					) u2
				GROUP BY
					u2.occurred,
					u2.shape
			) u3
		GROUP BY
			u3.shape
	) u4


--	3. Zmiana kszta³tu tekstu
SELECT
	u3.location,
	STRING_AGG(u3.shape, ', ') AS [shapes]
FROM
	(
		SELECT
			u2.location,
			u2.shape,
			COUNT(*) AS [reports]
		FROM
			(
				SELECT
					CASE
						WHEN 
							dbo.fnSplitString(
								dbo.fnSplitString(u.sighting_report, 'Duration', 1),
								'Shape: ', 2
							) = ''
							THEN
								'Unknown'
						WHEN 
							dbo.fnSplitString(
								dbo.fnSplitString(u.sighting_report, 'Duration', 1),
								'Shape: ', 2
							) = 'TRIANGULAR'
							THEN
								'Triangle'
						ELSE
							dbo.fnSplitString(
								dbo.fnSplitString(u.sighting_report, 'Duration', 1),
								'Shape: ', 2
							)
					END AS [shape],

					dbo.fnSplitString(
						dbo.fnSplitString(u.sighting_report, 'Shape', 1),
						'Location: ', 2
					) AS [location]

				FROM
					ufo u
			) u2
		GROUP BY
			u2.location,
			u2.shape
	) u3
GROUP BY
	u3.location


--		OUTPUT:
--	location				shapes
--	Aberdeen, MD		Disk, Sphere, Unknown, Light, Fireball, Other, Rectangle, Triangle
--	Aberdeen, NC		Light
--	Aberdeen, NJ		Cylinder, Teardrop
--	Aberdeen, SD		Light, Fireball, Formation
--	Aberdeen, WA		Disk, Cylinder, Triangle, Flash, Cross, Light
