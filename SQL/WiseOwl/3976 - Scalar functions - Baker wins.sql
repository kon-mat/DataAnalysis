USE DoctorWho
GO


ALTER FUNCTION fnReign (
	@StartDate DATE,
	@EndDate DATE = NULL
)
RETURNS INT
AS

BEGIN

	-- return difference in days between start and end date,
	-- using today's date as the end date if none is specified
	RETURN DATEDIFF(day, @StartDate, @EndDate)

END

GO


SELECT
	d.DoctorName,

	-- show number of days between first and last episode (for 
	-- Peter  Capaldi, use today's date)
	dbo.fnReign(d.FirstEpisodeDate, ISNULL(d.LastEpisodeDate, GetDate())) AS [Reign in days]
FROM 
	tblDoctor d
ORDER BY
	[Reign in days] DESC