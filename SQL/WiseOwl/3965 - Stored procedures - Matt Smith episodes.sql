USE DoctorWho
GO


ALTER PROC spMattSmithEpisodes @Year INT
AS
	SELECT 
		e.SeriesNumber AS [Series],
		e.EpisodeId AS [Episode],
		e.Title,
		e.EpisodeDate AS [Date of episode],
		d.DoctorName AS [Doctor]
	FROM
		tblEpisode e

		INNER JOIN tblDoctor d
			ON e.DoctorId = d.DoctorId

	WHERE
		d.DoctorName = 'Matt Smith'
		AND YEAR(e.EpisodeDate) = @Year
GO


EXEC spMattSmithEpisodes @Year = 2012