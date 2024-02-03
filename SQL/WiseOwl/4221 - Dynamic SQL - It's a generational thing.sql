USE WorldEvents
GO


-- show all events in given decade of birth (default to 1925)
ALTER PROCEDURE spDecade (
	@dob varchar(max) = '19250101'
)

AS

-- get start and end of decade
DECLARE @StartYear int = year(@dob) - year(@dob) % 10

DECLARE @Events varchar(max) = ''

SELECT
	@Events = @Events + 

	-- usually need a separating comma
	case 
		when len(@Events) > 0 then ','
		else ''
	end + 

	-- add on this event name
	quotename(e.EventName,'''')

FROM
	tblEvent e
WHERE
	year(e.EventDate) between @StartYear and @StartYear + 9


-- now build up SQL to list these events
DECLARE @sql varchar(max) = 'SELECT * FROM tblEvent WHERE EventName IN (' + @Events + ')'

EXEC (@sql)
GO

spDecade