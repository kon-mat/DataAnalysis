SELECT
	d.DoctorName,
	e.Title
FROM
	DoctorWho.dbo.tblDoctor d
INNER JOIN
	DoctorWho.dbo.tblEpisode e
	ON
		d.DoctorId = e.DoctorId
WHERE
	YEAR(e.EpisodeDate) = 2010
