USE WorldEvents
GO


-- show countries ...
SELECT
	c.CountryName
FROM
	tblCountry c
WHERE
	(
		-- ... which have more than 8 events
		SELECT
			COUNT(*)
		FROM
			tblEvent e
		WHERE
		e.CountryID = c.CountryID
	) > 8
ORDER BY
	c.CountryName





--SELECT
--	cc.CountryName
--FROM

--	(
--		SELECT
--			c.CountryName,
--			c.CountryID,
--			COUNT(*) AS [EventCount]
--		FROM
--			tblCountry c

--			INNER JOIN tblEvent e
--				ON c.CountryID = e.CountryID

--		GROUP BY
--			c.CountryName,
--			c.CountryID
--	) cc

--WHERE
--	cc.EventCount > 8
--ORDER BY
--	cc.CountryName ASC