USE DoctorWho
GO


CREATE PROC spEnemyEpisodes(
	@EnemyName VARCHAR(100)
)
AS

-- show all of the episodes featuring a particular enemy
SELECT DISTINCT
	ep.SeriesNumber,
	ep.EpisodeNumber,
	ep.Title
FROM
	tblEpisode ep

	INNER JOIN tblEpisodeEnemy ee
		ON ep.EpisodeId = ee.EnemyId

	INNER JOIN tblEnemy en
		ON ee.EnemyId = en.EnemyId

WHERE
	en.EnemyName LIKE '%' + @EnemyName + '%'
ORDER BY
	ep.SeriesNumber,
	ep.EpisodeNumber
GO

-- test this out
spEnemyEpisodes 'silence'