
-- variable to hold the types of episodes
DECLARE @ColumnList varchar(max) = ''

-- accumulate the episode types
SELECT 
	@ColumnList += 
		case
			when len(@ColumnList) = 0 then ''
			else ','
		end + quotename(left(e.EpisodeType,charindex(' ',e.EpisodeType,1)-1))
FROM
	tblEpisode AS e
GROUP BY
	e.EpisodeType
ORDER BY
	e.EpisodeType

-- show this worked!
--SELECT @ColumnList

DECLARE @sql varchar(max) = 'WITH Episodes AS (

	-- get the episode type and the 
	-- doctor for each episode
	SELECT 
		LEFT(e.EpisodeType,CHARINDEX('' '',e.EpisodeType,1)-1) AS EpisodeType,
		d.DoctorName,
		e.EpisodeId
	FROM
		tblEpisode AS e
		INNER JOIN tblDoctor AS d
			 ON e.DoctorId = d.DoctorId
)

SELECT * FROM Episodes
PIVOT (
	COUNT(Episodeid)
	FOR EpisodeType IN (' + @ColumnList + 
		')
) AS PivotTable'

EXEC(@sql)
