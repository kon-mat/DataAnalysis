USE DoctorWho
GO

ALTER FUNCTION fnEpisodeDescription (
	@Title VARCHAR(100)
)
RETURNS	VARCHAR(50)
AS

BEGIN
	
	DECLARE @PartDescription VARCHAR(50)

	-- look for words "part 1", "part 2" respectively
	SET @PartDescription =
		CASE

			-- if @Title contains 'part 1'
			WHEN CHARINDEX('part 1', @Title) > 0
				THEN 'First part'

			-- if @Title contains 'part 2'
			WHEN CHARINDEX('part 2', @Title) > 0
				THEN 'Second part'

			ELSE
				'Single episode'
		END
			
	RETURN @PartDescription
END
GO


-- show episodes with descriptions
SELECT
	e.EpisodeId,
	e.Title,
	dbo.fnEpisodeDescription(e.Title) AS [Description]
FROM
	tblEpisode e

-- count number of episodes of each type
SELECT
	dbo.fnEpisodeDescription(e.Title) AS [Episode type],
	COUNT(*) AS [Number of episodes]
FROM
	tblEpisode e
GROUP BY
	dbo.fnEpisodeDescription(e.Title)