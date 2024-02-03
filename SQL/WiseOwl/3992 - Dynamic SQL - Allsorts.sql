USE DoctorWho
GO


ALTER PROCEDURE spEpisodesSorted (
	@SortColumn varchar(100) = 'SeriesNumber'
	, @SortOrder varchar(100) = 'asc'
)
AS

DECLARE @sql varchar(max)

SET @sql = 
	'SELECT * FROM tblEpisode ORDER BY ' +
	@SortColumn + ' ' + @SortOrder

EXEC(@sql)

GO


EXEC spEpisodesSorted
GO


EXEC spEpisodesSorted 'EpisodeId', 'desc'


