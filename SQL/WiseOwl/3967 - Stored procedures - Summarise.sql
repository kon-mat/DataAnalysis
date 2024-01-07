USE DoctorWho
GO



CREATE PROC spSummariseEpisodes
AS

	-- the 3 most frequently-appearing companions
	SELECT 
		TOP(3) c.CompanionName,
		COUNT(DISTINCT e.EpisodeId) AS [Episodes]
	FROM
		tblEpisode e

		INNER JOIN tblEpisodeCompanion ec
		 ON e.EpisodeId = ec.EpisodeId

		INNER JOIN tblCompanion c
			ON ec.CompanionId = c.CompanionId

	GROUP BY
		c.CompanionName
	ORDER BY
		[Episodes] DESC

	-- the 3 most frequently-appearing enemies
	SELECT 
		TOP(3) en.EnemyName,
		COUNT(DISTINCT e.EpisodeId) AS [Episodes]
	FROM
		tblEpisode e

		INNER JOIN tblEpisodeEnemy ee
		 ON e.EpisodeId = ee.EpisodeId

		INNER JOIN tblEnemy en
			ON ee.EnemyId = en.EnemyId

	GROUP BY
		en.EnemyName
	ORDER BY
		[Episodes] DESC

GO


EXEC spSummariseEpisodes


