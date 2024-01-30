USE YT_Stats
GO


ALTER VIEW 
	dbo.vwCleanYouTubeStats
AS
	SELECT
		yt.rank,

		-- replace incorrect characters in name
		CASE
			WHEN LTRIM(RTRIM(REPLACE(yt.Youtuber, 'ý', ''))) = '' THEN 'Incorrect name'
			ELSE LTRIM(RTRIM(REPLACE(yt.Youtuber, 'ý', '')))
		END AS [channel_name],

		yt.subscribers,
		yt.video_views,

		-- boolean: if Official YoutTube Channel (video_views = 0)
		CASE
			WHEN yt.video_views = 0 THEN 1
			ELSE 0
		END AS [official_yt_channel],

		CASE
			WHEN yt.category IS NULL THEN 'No category'
			ELSE yt.category
		END AS [category],

		CASE
			WHEN yt.Country IS NULL THEN 'Country not specified'
			ELSE yt.Country
		END AS [country],

		CASE
			WHEN yt.Abbreviation IS NULL THEN ''
			ELSE yt.Abbreviation
		END AS [abbreviation],

		CASE
			WHEN yt.channel_type IS NULL THEN yt.category
			ELSE yt.channel_type
		END AS [channel_type],

		yt.video_views_rank,

		CASE
			WHEN yt.video_views_for_the_last_30_days IS NULL THEN 0
			ELSE yt.video_views_for_the_last_30_days
		END AS [video_views_for_the_last_30_days],

		yt.lowest_monthly_earnings,
		yt.highest_monthly_earnings,
		yt.lowest_yearly_earnings,
		yt.highest_yearly_earnings,

		CASE
			WHEN yt.subscribers_for_last_30_days IS NULL THEN 0
			ELSE yt.subscribers_for_last_30_days
		END AS [subscribers_for_last_30_days],

		-- boolean: if created date is not null (video_views = 0)
		CASE
			WHEN yt.created_year IS NOT NULL
				AND yt.created_month IS NOT NULL
				AND yt.created_date IS NOT NULL 
				THEN 1
			ELSE 0
		END AS [created_date_avaible],

		yt.created_year,
		yt.created_month,
		yt.created_date AS [created_day],
	
		-- create date from year, month and day columns
		CAST(
			CAST(yt.created_year AS varchar) + '-' + 
			CAST(
				CASE 
					WHEN yt.created_month = 'Jan' THEN 01
					WHEN yt.created_month = 'Feb' THEN 02
					WHEN yt.created_month = 'Mar' THEN 03
					WHEN yt.created_month = 'Apr' THEN 04
					WHEN yt.created_month = 'May' THEN 05
					WHEN yt.created_month = 'Jun' THEN 06
					WHEN yt.created_month = 'Jul' THEN 07
					WHEN yt.created_month = 'Aug' THEN 08
					WHEN yt.created_month = 'Sep' THEN 09
					WHEN yt.created_month = 'Oct' THEN 10
					WHEN yt.created_month = 'Nov' THEN 11
					WHEN yt.created_month = 'Dec' THEN 12
				END
			AS varchar) + '-' +
			CAST(yt.created_date AS varchar)
		AS date) AS [created_date],

		-- calculate time of activity on YouTube
		DATEDIFF(
			month,
			CAST(
				CAST(yt.created_year AS varchar) + '-' + 
				CAST(
					CASE 
						WHEN yt.created_month = 'Jan' THEN 01
						WHEN yt.created_month = 'Feb' THEN 02
						WHEN yt.created_month = 'Mar' THEN 03
						WHEN yt.created_month = 'Apr' THEN 04
						WHEN yt.created_month = 'May' THEN 05
						WHEN yt.created_month = 'Jun' THEN 06
						WHEN yt.created_month = 'Jul' THEN 07
						WHEN yt.created_month = 'Aug' THEN 08
						WHEN yt.created_month = 'Sep' THEN 09
						WHEN yt.created_month = 'Oct' THEN 10
						WHEN yt.created_month = 'Nov' THEN 11
						WHEN yt.created_month = 'Dec' THEN 12
					END
				AS varchar) + '-' +
				CAST(yt.created_date AS varchar)
			AS date),
			CAST(CURRENT_TIMESTAMP AS date)
		) AS [months_on_YT],

		yt.Gross_tertiary_education_enrollment AS [gross_tertiary_education_enrollment],
		yt.Population AS [population],
		yt.Unemployment_rate AS [unemployment_rate],
		yt.Urban_population AS [urban_population],
		yt.Latitude AS [latitude],
		yt.Longitude AS [longitude],

		yt.video_views / yt.subscribers AS [views_per_subs],

		yt.subscribers /
			DATEDIFF(
				month,
				CAST(
					CAST(yt.created_year AS varchar) + '-' + 
					CAST(
						CASE 
							WHEN yt.created_month = 'Jan' THEN 01
							WHEN yt.created_month = 'Feb' THEN 02
							WHEN yt.created_month = 'Mar' THEN 03
							WHEN yt.created_month = 'Apr' THEN 04
							WHEN yt.created_month = 'May' THEN 05
							WHEN yt.created_month = 'Jun' THEN 06
							WHEN yt.created_month = 'Jul' THEN 07
							WHEN yt.created_month = 'Aug' THEN 08
							WHEN yt.created_month = 'Sep' THEN 09
							WHEN yt.created_month = 'Oct' THEN 10
							WHEN yt.created_month = 'Nov' THEN 11
							WHEN yt.created_month = 'Dec' THEN 12
						END
					AS varchar) + '-' +
					CAST(yt.created_date AS varchar)
				AS date),
				CAST(CURRENT_TIMESTAMP AS date)
			) AS [subs_growth_per_year]

	FROM
		YouTubeStatistics yt
