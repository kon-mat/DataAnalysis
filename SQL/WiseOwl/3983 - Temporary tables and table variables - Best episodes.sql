USE DoctorWho
GO


-- create a table to hold the "best" episodes
DECLARE @BestEpisodes TABLE (
	EpisodeId int identity(1,1) primary key,
	Title varchar(255),
	SeriesNumber int,
	EpisodeNumber int,
	Why varchar(100)
)

-- add into this the Stephen Moffat episodes
INSERT INTO @BestEpisodes (
	Title,
	SeriesNumber,
	EpisodeNumber,
	Why
)
SELECT
	e.Title,
	e.SeriesNumber,
	e.EpisodeNumber,
	'Steven Moffat'
FROM
	tblEpisode as e
	INNER JOIN tblAuthor as a on e.AuthorId = a.AuthorId
WHERE
	a.AuthorName = 'Steven Moffat'
ORDER BY
	SeriesNumber,
	EpisodeNumber


-- add into this the Amy Pond episodes
INSERT INTO @BestEpisodes(
	Title,
	SeriesNumber,
	EpisodeNumber,
	Why
)
SELECT
	e.Title,
	e.SeriesNumber,
	e.EpisodeNumber,
	'Featuring Amy Pond'
FROM
	tblEpisode AS e
	INNER JOIN tblEpisodeCompanion AS ec ON e.EpisodeId = ec.EpisodeCompanionId
	INNER JOIN tblCompanion AS c ON ec.CompanionId = c.CompanionId
WHERE
	c.CompanionName = 'Amy Pond'


-- show the results
SELECT * FROM @BestEpisodes


-- show titles appearing more than once
SELECT 
	Title,
	COUNT(*) AS 'Number of mentions'
FROM
	@BestEpisodes
GROUP BY
	Title
HAVING
	COUNT(*) > 1
ORDER BY
	--'Number of mentions' DESC,
	Title ASC