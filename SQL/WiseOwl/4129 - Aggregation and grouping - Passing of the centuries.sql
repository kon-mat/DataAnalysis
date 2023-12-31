USE WorldEvents



SELECT

	-- derive the century
	CASE
		WHEN YEAR(e.EventDate) < 1800 THEN '18th century'
		WHEN YEAR(e.EventDate) < 1900 THEN '19th century'
		WHEN YEAR(e.EventDate) < 2000 THEN '20th century'
		ELSE '21st century'
	END AS Century,
	
	COUNT(*) AS [Number events]

FROM
	dbo.tblEvent e

GROUP BY

	-- need to group by the century too (the CUBE function shows the grand total too)
	CUBE(
		CASE
			WHEN year(e.EventDate) < 1800 THEN '18th century'
			WHEN year(e.EventDate) < 1900 THEN '19th century'
			WHEN year(e.EventDate) < 2000 THEN '20th century'
			ELSE '21st century'
		END 
	)

ORDER BY
	Century