USE DoctorWho
GO


ALTER PROC spCompanionsForDoctor (
	@DoctorName VARCHAR(50) = NULL
)
AS

-- show all of the companions who have accompanied this doctor
SELECT
	DISTINCT c.CompanionName
FROM
	tblDoctor d

	INNER JOIN tblEpisode e
		ON e.DoctorId = d.DoctorId

	INNER JOIN tblEpisodeCompanion ec
		ON e.EpisodeId = ec.EpisodeId

	INNER JOIN tblCompanion c
		ON ec.CompanionId = c.CompanionId

WHERE
	-- either the doctor matches the name chosen, or show all companions
	-- if the doctor name parameter isn't specified
	d.DoctorName LIKE '%' + @DoctorName + '%'
	OR @DoctorName IS NULL
ORDER BY
	c.CompanionName
GO

-- show 3 companions for Christpher Eccleston
spCompanionsForDoctor 'Ecc'
GO

-- show 5 companions for Matt Smith
spCompanionsForDoctor 'matt'
GO

-- show 17 companions for any doctor
spCompanionsForDoctor 
GO