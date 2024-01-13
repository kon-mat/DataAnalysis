USE DoctorWho
GO


ALTER PROC spGoodAndBad (
	@SeriesNumber INT,
	@NumberEnemies INT OUTPUT,
	@NumberCompanions INT OUTPUT
)
AS

DECLARE @enemies int = (
	SELECT 
		COUNT(DISTINCT ee.EnemyId)
	FROM 
		tblEpisodeEnemy AS ee

		INNER JOIN tblEpisode e 
			ON ee.EpisodeId = e.EpisodeId

	WHERE
		e.SeriesNumber = @SeriesNumber
)

DECLARE @companions int = (
	SELECT 
		COUNT(DISTINCT CompanionId)
	FROM 
		tblEpisodeCompanion ec

		INNER JOIN tblEpisode e 
			ON ec.EpisodeId = e.EpisodeId

	WHERE
		e.SeriesNumber = @SeriesNumber
)

-- return both numbers
SET @NumberEnemies = @enemies
SET @NumberCompanions =  @companions

GO



DECLARE @SeriesNumber INT = 3
DECLARE @NumEnemies INT
DECLARE @NumCompanions INT

EXEC spGoodAndBad 
	@SeriesNumber, 
	@NumEnemies OUTPUT, 
	@NumCompanions OUTPUT

-- show the results
SELECT 
	@SeriesNumber AS 'Series number',
	@NumEnemies AS 'Number of enemies',
	@NumCompanions AS 'Number of companions'