USE DoctorWho
GO


ALTER FUNCTION dbo.fnEpisodesByDoctor (
	@Doctor varchar(100)
)
RETURNS TABLE
AS

RETURN
	SELECT
		e.EpisodeId
		, e.Title
		, e.SeriesNumber
		, e.EpisodeNumber
		, e.AuthorId
	FROM
		tblEpisode e
		INNER JOIN tblDoctor d on e.DoctorId = d.DoctorId
	WHERE
		d.DoctorName like '%' + @Doctor + '%'
GO



SELECT
	ebd.SeriesNumber
	, ebd.EpisodeNumber
	, ebd.Title
	, a.AuthorName
FROM
	dbo.fnEpisodesByDoctor('Chris') ebd
	INNER JOIN tblAuthor a on ebd.AuthorId = a.AuthorId

