USE DoctorWho



SELECT
	YEAR(e.EpisodeDate) AS [Episode year],
	en.EnemyName,
	COUNT(*) AS [Number of episodes]

FROM
	dbo.tblEpisode e

	INNER JOIN dbo.tblDoctor d
		ON e.DoctorId = d.DoctorId

	INNER JOIN dbo.tblEpisodeEnemy ee
		ON e.EpisodeId = ee.EpisodeId

	INNER JOIN dbo.tblEnemy en
		ON ee.EnemyId = en.EnemyId

WHERE
	YEAR(d.BirthDate) < 1970

GROUP BY
	YEAR(e.EpisodeDate),
	en.EnemyName

HAVING
	COUNT(*) > 1

ORDER BY
	[Number of episodes] DESC


