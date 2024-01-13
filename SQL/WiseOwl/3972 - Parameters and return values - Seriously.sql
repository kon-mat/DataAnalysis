USE DoctorWho
GO


CREATE PROC spListEpisodes (
	@SeriesNumber INT = NULL
)
AS

-- list out all of the episodes for a given series of Dr Who
SELECT
	e.Title,
	e.SeriesNumber,
	e.EpisodeNumber
FROM
	tblEpisode e
WHERE
	-- if no parameter specified, series number will be null
	-- and we'll get every single episode
	SeriesNumber = @SeriesNumber
	OR @SeriesNumber IS NULL
GO
	
-- show all of the episodes
EXEC spListEpisodes