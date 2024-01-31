USE YT_Stats
GO


ALTER VIEW 
	dbo.vwCategoryYouTubeStats
AS
	SELECT
		yt.category,
		COUNT(yt.rank) AS [number_of_channels],
		SUM(CAST(yt.subscribers AS bigint)) AS [total_subscribers],
		SUM(CAST(yt.video_views AS bigint)) AS [total_video_views],
		SUM(CAST(yt.video_views AS bigint)) / SUM(CAST(yt.subscribers AS bigint)) AS [views_per_subs]
	FROM
		dbo.vwCleanYouTubeStats yt
	WHERE
		yt.country != 'Country not specified'
		AND yt.official_yt_channel = 0
	GROUP BY
		yt.category
