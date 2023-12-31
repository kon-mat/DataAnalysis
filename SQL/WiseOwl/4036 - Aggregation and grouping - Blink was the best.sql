USE DoctorWho



SELECT
	a.AuthorName,

	-- show number of episodes
	COUNT(*) AS [Episodes],

	-- show first and last ones made
	MIN(e.EpisodeDate) AS [Earliest date],
	MAX(e.EpisodeDate) AS [Latest date]

FROM
	dbo.tblAuthor a

	INNER JOIN dbo.tblEpisode e
		ON a.AuthorId = e.AuthorId

GROUP BY
	a.AuthorName

ORDER BY
	-- most prolific author first
	[Episodes] DESC
