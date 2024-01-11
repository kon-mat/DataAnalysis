USE DoctorWho
GO



-- show the details for a given doctor
DECLARE @DoctorNumber INT = 9

-- get the id number and name of this doctor
DECLARE @DoctorId INT
DECLARE @DoctorName VARCHAR(100)

-- set the name of this doctor
SELECT
	@DoctorId = DoctorId,
	@DoctorName = DoctorName
FROM
	tblDoctor 
WHERE
	DoctorNumber = @DoctorNumber

-- get number of episodes
DECLARE @NumberEpisodes INT = (
	SELECT 
		COUNT(*) 
	FROM 
		tblEpisode e
	WHERE 
		e.DoctorId = @DoctorId
)

-- show progress to date
PRINT ''
PRINT 'Results for doctor number ' + CAST(@DoctorId AS VARCHAR(100))
PRINT '----------------------------'
PRINT ''
PRINT 'Doctor name: ' + upper(@DoctorName)
PRINT ''
PRINT 'Episodes appeared in: ' + CAST(@NumberEpisodes AS VARCHAR(10))