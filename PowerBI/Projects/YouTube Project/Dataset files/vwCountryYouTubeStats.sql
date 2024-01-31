USE YT_Stats
GO


ALTER VIEW 
	dbo.vwCountryYouTubeStats
AS
	SELECT
		yt.country,
		COUNT(yt.rank) AS [number_of_channels],
		SUM(CAST(yt.subscribers AS bigint)) AS [total_subscribers],
		SUM(CAST(yt.video_views AS bigint)) AS [total_video_views],
		MAX(yt.gross_tertiary_education_enrollment) AS [gross_tertiary_education_enrollment],
		MAX(yt.population) AS [population],
		MAX(yt.unemployment_rate) AS [unemployment_rate],
		MAX(yt.urban_population) AS [urban_population],
		MAX(yt.latitude) AS [latitude],
		MAX(yt.longitude) AS [longitude],
		SUM(CAST(yt.video_views AS bigint)) / SUM(CAST(yt.subscribers AS bigint)) AS [views_per_subs],
		SUM(CAST(yt.video_views AS bigint)) / MAX(yt.urban_population) AS [views_per_population]

	FROM
		dbo.vwCleanYouTubeStats yt
	WHERE
		yt.country != 'Country not specified'
		AND yt.official_yt_channel = 0
	GROUP BY
		yt.country
