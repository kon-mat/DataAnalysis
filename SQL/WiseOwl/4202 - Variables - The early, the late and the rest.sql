USE WorldEvents
GO


DECLARE @EarliestDate DATE
DECLARE @LatestDate DATE
DECLARE @NumberOfEvents INT
DECLARE @EventInfo VARCHAR(255)

SELECT
	@EarliestDate = MIN(e.EventDate),
	@LatestDate =	MAX(e.EventDate),
	@NumberOfEvents = COUNT(*),
	@EventInfo = 'Summary of events'
FROM
	tblEvent e


SELECT
	@EventInfo AS Title,
	@EarliestDate AS [Earliest Date],
	@LatestDate AS [Latest Date],
	@NumberOfEvents AS [Number Of Events]