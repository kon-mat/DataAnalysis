USE WorldEvents
GO


SELECT
	cnt.ContinentName,
	e.EventName
FROM
	tblEvent e

	INNER JOIN tblCountry ctr
		ON e.CountryID = ctr.CountryID

	INNER JOIN tblContinent cnt
		ON ctr.ContinentID = cnt.ContinentID

WHERE
	cnt.ContinentName IN (
		SELECT
			TOP 3 e.ContinentName
		FROM
			(
				SELECT
					cnt.ContinentName,
					ev.EventName
				FROM	
					tblEvent ev

					INNER JOIN tblCountry ctr
						ON ev.CountryID = ctr.CountryID

					INNER JOIN tblContinent cnt
						ON ctr.ContinentID = cnt.ContinentID
			) e
		GROUP BY
			e.ContinentName
		ORDER BY
			COUNT(*) ASC
	) 
