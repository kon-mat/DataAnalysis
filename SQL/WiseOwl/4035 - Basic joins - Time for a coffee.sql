USE DoctorWho

SELECT
	a.AuthorName,
	e.Title,
	d.DoctorName,
	en.EnemyName,

	-- total length of the four columns being shown
	LEN(a.AuthorName) + LEN(e.Title) + 
	LEN(d.DoctorName) + LEN(en.EnemyName)	AS 'Total Length'

FROM

	dbo.tblAuthor a

INNER JOIN
	dbo.tblEpisode e
	ON
		a.AuthorId = e.AuthorId

INNER JOIN
	dbo.tblDoctor d
	ON
		e.DoctorId = d.DoctorId

INNER JOIN
	dbo.tblEpisodeEnemy ee
	ON
		e.EpisodeId = ee.EpisodeId

INNER JOIN
	dbo.tblEnemy en
	ON
		ee.EnemyId = en.EnemyId

WHERE
	LEN(a.AuthorName) + LEN(e.Title) + LEN(d.DoctorName) + LEN(en.EnemyName) < 40

ORDER BY
	e.SeriesNumber,
	e.EpisodeNumber