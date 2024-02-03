USE Books
GO


/*

	We're aiming for a stored procedure which will
	allow us to dynamically create SQL commands - eg:

	SELECT TOP 5 
		FirstName,LastName 
	FROM tblPerson 
	ORDER BY LastName

	SELECT TOP 3 
		OrgId,OrgName,SectorId 
	FROM tblOrg 
	ORDER BY OrgName

	SELECT TOP 10
		CourseId, CourseName
	FROM
		tblCourse
	ORDER BY
		CourseName

*/


ALTER PROCEDURE spSelect (
	@Columns varchar(100)
	, @TableName varchar(50)
	, @NumberRows int
	, @OrderColumn varchar(50)
)
AS

DECLARE @SqlString varchar(1000)

SET @SqlString = 'SELECT TOP ' +
	CAST(@NumberRows as varchar(5)) +
	' ' + @Columns +
	' FROM ' + @TableName +
	' ORDER BY ' + @OrderColumn

	-- for debug, show what this command would look like
PRINT @SqlString

-- run it!
EXEC (@SqlString)

GO




-- now try this out with a couple of commands
EXEC spSelect 
	@Columns = 'BookId, BookName', 
	@TableName = 'tblBook', 
	@NumberRows = 5, 
	@OrderColumn = 'BookId'

EXEC spSelect 'AuthorId, FirstName, LastName', 'tblAuthor', 3, 'LastName'