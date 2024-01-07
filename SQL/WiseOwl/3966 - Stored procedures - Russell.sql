USE DoctorWho
GO



ALTER PROC spMoffats @AuthorName VARCHAR(100)
AS
	SELECT
		e.Title,
		a.AuthorName
	FROM
		tblEpisode e

		INNER JOIN tblAuthor a
			ON e.AuthorId = a.AuthorId

	WHERE
		a.AuthorName LIKE '%' + @AuthorName + '%'
GO


EXEC spMoffats @AuthorName = 'Russell'


