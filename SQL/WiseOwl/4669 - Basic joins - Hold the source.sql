USE Movies_02


SELECT
	f.Title,
	s.Source
FROM
	dbo.Film f

	-- link to the table of sources for each film
	JOIN dbo.Source s
		ON f.SourceID = s.SourceID

WHERE
	-- show the ones where the source is NA
	s.SourceID = 'NA'
ORDER BY
	f.Title