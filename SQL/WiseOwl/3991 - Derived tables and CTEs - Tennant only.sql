

-- for each David Tennant episode, show for each enemy the number of times this enemy
-- appears in non-David Tennant episodes
WITH TennantEpisodes AS (
	SELECT
		e.EpisodeId,
		ee.EnemyId,
	
		(
			SELECT COUNT(*) 
			FROM 
				tblEpisodeEnemy AS subEE 
				INNER JOIN tblEpisode AS subE ON subEE.EpisodeId = subE.EpisodeId
				INNER JOIN tblDoctor AS subD ON subE.DoctorId = subd.DoctorId
			WHERE 
				subd.DoctorName <> 'David Tennant' and
				subEE.EnemyId = ee.EnemyId
		) AS OtherAppearances

	FROM 
		tblEpisode AS e
		INNER JOIN tblEpisodeEnemy AS ee ON e.EpisodeId = ee.EpisodeId
		INNER JOIN tblDoctor AS d ON e.DoctorId = d.DoctorId
	WHERE
		d.DoctorName = 'David Tennant' 
)

-- use this to 
SELECT
	e.EpisodeId,
	ep.Title,
	SUM(e.OtherAppearances) AS Cameos
FROM
	TennantEpisodes AS e
	INNER JOIN tblEpisode AS ep ON e.EpisodeId = ep.EpisodeId
GROUP BY
	e.EpisodeId,
	ep.Title
HAVING 
	SUM(e.OtherAppearances) = 0 
	
