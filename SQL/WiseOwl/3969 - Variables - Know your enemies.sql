USE DoctorWho
GO

-- choose a specific episode
DECLARE @EpisodeId INT = 15

-- variable to hold the list of enemies
DECLARE @EnemyList VARCHAR(100) = ''


SELECT

	-- every row write new value to variable
	@EnemyList = @EnemyList +
		CASE
			WHEN LEN(@EnemyList) > 0 THEN ', '
			ELSE ''
		END + e.EnemyName

FROM
	tblEpisodeEnemy ee

	INNER JOIN tblEnemy e
		ON ee.EnemyId = e.EnemyId

WHERE
	ee.EpisodeId = @EpisodeId



-- show the results
SELECT 
	@EpisodeId as 'Episode id',
	@EnemyList AS 'Enemies'