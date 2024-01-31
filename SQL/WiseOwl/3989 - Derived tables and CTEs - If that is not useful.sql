USE DoctorWho
GO


WITH EpisodesMPAuthors as (
	SELECT
		e.EpisodeId
	FROM
		tblEpisode e
		INNER JOIN tblAuthor a on e.AuthorId = a.AuthorId
	WHERE
		a.AuthorName like '%mp%'
)


SELECT DISTINCT
	c.CompanionName
FROM
	EpisodesMPAuthors ema
	INNER JOIN tblEpisode e on ema.EpisodeId = e.EpisodeId
	INNER JOIN tblEpisodeCompanion ec on e.EpisodeId = ec.EpisodeId
	INNER JOIN tblCompanion c on ec.CompanionId = c.CompanionId

