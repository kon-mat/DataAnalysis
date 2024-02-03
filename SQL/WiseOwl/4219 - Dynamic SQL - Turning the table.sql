USE WorldEvents
GO


ALTER PROCEDURE spChangingTables (
	@TableName varchar(100) = 'tblEvent'
)
AS

DECLARE @sql varchar(1000) = 'SELECT * FROM ' + @TableName

EXEC(@sql)

GO


EXEC spChangingTables
GO

EXEC spChangingTables 'tblCategory'






