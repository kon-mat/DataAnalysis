USE DoctorWho
GO


-- declare variables
DECLARE @EpisodeName VARCHAR(255) = 'The Stolen Earth (Part 1)'
DECLARE @EpisodeId INT = 54
DECLARE @NumberCompanions INT = 2
DECLARE @NumberEnemies INT = 2

-- list out the details for this episode
SELECT
	@EpisodeName as Title,
	@EpisodeId as 'Episode id',
	@NumberCompanions as 'Number of companions',
	@NumberEnemies as 'Number of enemies'



-- declare variables 2
DECLARE @EpisodeId2 INT = 42

DECLARE @EpisodeName2 VARCHAR(255) = (
	SELECT
		e.Title
	FROM
		tblEpisode e
	WHERE
		e.EpisodeId = @EpisodeId2
)

DECLARE @NumberCompanions2 INT = (
	SELECT
		COUNT(DISTINCT ep.EpisodeCompanionId)
	FROM
		tblEpisodeCompanion ep
	WHERE
		ep.EpisodeId = @EpisodeId2
)

DECLARE @NumberEnemies2 INT = (
	SELECT
		COUNT(DISTINCT ee.EnemyId)
	FROM
		tblEpisodeEnemy ee
	WHERE
		ee.EpisodeId = @EpisodeId2
)


-- list out the details for this episode 2
SELECT
	@EpisodeName2 as Title,
	@EpisodeId2 as 'Episode id',
	@NumberCompanions2 as 'Number of companions',
	@NumberEnemies2 as 'Number of enemies'
