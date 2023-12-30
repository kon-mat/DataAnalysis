USE DoctorWho

SELECT

	-- show the episode title, enemy and author
	ep.Title,
	en.EnemyName,
	a.AuthorName

FROM

	-- start with authors, and work our way across
	dbo.tblAuthor a

INNER JOIN
	dbo.tblEpisode ep
	ON
		a.AuthorId = ep.AuthorId

INNER JOIN
	dbo.tblEpisodeEnemy ee
	ON
		ep.EpisodeId = ee.EpisodeId

INNER JOIN
	dbo.tblEnemy en
	ON
		ee.EnemyId = en.EnemyId

WHERE
	en.EnemyName LIKE '%Dalek%'
