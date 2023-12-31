USE DoctorWho



SELECT
	-- show the author and doctor
	a.AuthorName,
	d.DoctorName,

	-- show number of episodes
	COUNT(*) AS [Episodes]

FROM
	dbo.tblAuthor a

	INNER JOIN dbo.tblEpisode e
		ON a.AuthorId = e.AuthorId
	
	INNER JOIN dbo.tblDoctor d
		ON e.DoctorId = d.DoctorId

GROUP BY
	a.AuthorName,
	d.DoctorName

HAVING
	COUNT(*) > 5

ORDER BY
	[Episodes] DESC