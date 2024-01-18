USE DoctorWho
GO


CREATE FUNCTION fnNumberCompanions (
	@EpisodeId INT
)
RETURNS INT
AS

BEGIN

	-- count how many companions there are for a given episode
	RETURN (
		SELECT
			COUNT(DISTINCT ec.CompanionId)
		FROM
			tblEpisodeCompanion ec
		WHERE
			ec.EpisodeId = @EpisodeId
	)

END

GO


CREATE FUNCTION fnNumberEnemies (
	@EpisodeId INT
)
RETURNS INT
AS

BEGIN

	-- count how many enemies there are for a given episode
	RETURN (
		SELECT
			COUNT(DISTINCT ee.EnemyId)
		FROM
			tblEpisodeEnemy ee
		WHERE
			ee.EpisodeId = @EpisodeId
	)

END

GO


CREATE FUNCTION fnWords (
	@String VARCHAR(MAX)
)
RETURNS INT
AS

BEGIN

	-- count how many words there are in a given string of text
	-- (assumes no double spaces in words)
	DECLARE @s VARCHAR(MAX)

	-- first remove leading and closing spacing
	SET @s = RTRIM(LTRIM(@String))

	-- now find how many letters there are with and without spaces
	DECLARE @WithSpaces INT
	DECLARE @WithoutSpaces INT

	SET @WithSpaces = LEN(@s)
	SET @WithoutSpaces = LEN(REPLACE(@s, ' ', ''))

	-- the number of spaces removed, plus one, is number of words (ish)
	RETURN @WithSpaces - @WithoutSpaces + 1

END

GO



-- show all these functions working
SELECT
	EpisodeId,
	Title,

	-- function to count number of companions for a given episode
	dbo.fnNumberCompanions(EpisodeId) AS Companions,

	-- function to count the number of enemies for an episode
	dbo.fnNumberEnemies(EpisodeId) AS Enemies,

	-- function to count the number of words (hint: use a combination
	-- of LTRIM and RTRIM to remove leading and trailing spaces, then
	-- REPLACE to change all spaces to empty strings and compare the
	-- LEN of the string before and after this change!)
	dbo.fnWords(Title) AS Words

FROM
	tblEpisode
ORDER BY
	Words DESC