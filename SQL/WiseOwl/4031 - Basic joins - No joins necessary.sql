
SELECT
	a.AuthorName,
	e.Title,
	e.EpisodeType
FROM
	DoctorWho.dbo.tblAuthor a
LEFT JOIN
	DoctorWho.dbo.tblEpisode e
	ON
		a.AuthorId = e.AuthorId
WHERE
	e.EpisodeType LIKE '%special%'
ORDER BY
	e.Title