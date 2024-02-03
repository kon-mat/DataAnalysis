USE DoctorWho
GO


WITH EpisodeDetails as
(
	SELECT
		year(e.EpisodeDate) as EpisodeYear
		, e.SeriesNumber
		, e.EpisodeId
	FROM
		tblEpisode e
)


SELECT *
FROM EpisodeDetails
PIVOT (
	count(EpisodeId)
	for SeriesNumber in (
		[1], [2], [3], [4], [5], [6], [7], [8], [9]
	)
) as PivotTable


