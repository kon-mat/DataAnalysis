USE DoctorWho
GO


ALTER FUNCTION fnSilly (
	@CompanionName varchar(100)
	, @EnemyName varchar(100)
)
RETURNS @episodes TABLE (
	SeriesNumber int
	, EpisodeNumber int
	, Title varchar(100)
	, Doctor varchar(100)
	, Author varchar(100)
	, Appearing varchar(max)
)
AS
BEGIN

	-- get the list of episodes featuring this companion
	INSERT INTO @episodes (
		SeriesNumber,
		EpisodeNumber,
		Title,
		Doctor,
		Author,
		Appearing
	)
	SELECT
		e.SeriesNumber,
		e.EpisodeNumber,
		e.Title,
		d.DoctorName,
		a.AuthorName,
		dbo.fnCompanions(e.EpisodeId)
	FROM
		tblEpisode AS e
		INNER JOIN tblEpisodeCompanion AS ec ON e.EpisodeId = ec.EpisodeId
		INNER JOIN tblCompanion AS c ON ec.CompanionId = c.CompanionId
		INNER JOIN tblDoctor AS d ON e.DoctorId = d.DoctorId
		INNER JOIN tblAuthor AS a ON e.AuthorId = a.AuthorId
	WHERE
		c.CompanionName like '%' + @CompanionName + '%'

	-- add in the episodes featuring this enemy
	INSERT INTO @episodes(
		SeriesNumber,
		EpisodeNumber,
		Title,
		Doctor,
		Author,
		Appearing
	)
	SELECT
		e.SeriesNumber,
		e.EpisodeNumber,
		e.Title,
		d.DoctorName,
		a.AuthorName,
		dbo.fnEnemies(e.EpisodeId)
	FROM
		tblEpisode AS e
		INNER JOIN tblEpisodeEnemy AS ey ON e.EpisodeId = ey.EpisodeId
		INNER JOIN tblEnemy AS y ON ey.EnemyId = y.EnemyId
		INNER JOIN tblDoctor AS d ON e.DoctorId = d.DoctorId
		INNER JOIN tblAuthor AS a ON e.AuthorId = a.AuthorId
	WHERE
		y.EnemyName like '%' + @EnemyName + '%' 

	RETURN

END
GO


-- show episodes featuring either Wilfred Mott or The Ood
SELECT * FROM dbo.fnSilly('wilf','ood')