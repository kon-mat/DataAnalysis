USE DoctorWho



SELECT
	-- report the companion's name
	c.CompanionName

FROM
	-- show ALL of the companions, and episode details where they exist
	dbo.tblCompanion c
	LEFT OUTER JOIN dbo.tblEpisodeCompanion ec
		ON c.CompanionId = ec.CompanionId

WHERE
		-- don't show companions who have corresponding episodes
	ec.EpisodeCompanionId IS NULL