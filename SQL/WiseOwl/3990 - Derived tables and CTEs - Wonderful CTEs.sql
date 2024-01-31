USE DoctorWho
GO


-- get a list of episodes featuring Rose Tyler and David Tennant
WITH ChosenEpisodes as (

	SELECT

		-- show the names just for checking purposes (don't need it)
		e.EpisodeId,
		c.CompanionName,
		d.DoctorName

	FROM 
		tblEpisode e
		INNER JOIN tblEpisodeCompanion ec on e.EpisodeId = ec.EpisodeId
		INNER JOIN tblCompanion c on ec.CompanionId = c.CompanionId
		INNER JOIN tblDoctor d on e.DoctorId = d.DoctorId
	WHERE
		c.CompanionName = 'Rose Tyler'
		and d.DoctorName != 'David Tennant'
)



-- show enemies appearing in these
SELECT DISTINCT
	y.EnemyName
FROM
	ChosenEpisodes
	INNER JOIN tblEpisode AS e ON ChosenEpisodes.EpisodeId = e.EpisodeId
	INNER JOIN tblEpisodeEnemy AS ee ON e.EpisodeId = ee.EpisodeId
	INNER JOIN tblEnemy AS y ON ee.EnemyId = y.EnemyId
ORDER BY 
	y.EnemyName