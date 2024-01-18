USE WorldEvents
GO

ALTER FUNCTION fnEventWinner (
	@EventName VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS

BEGIN

	DECLARE @EventType VARCHAR(MAX) = ''

	SET @EventType = 
		CASE

			WHEN @EventName IN (
				SELECT TOP 1 e.EventName
				FROM tblEvent e
				ORDER BY e.EventName ASC
			)
				THEN 'First alphabetically'

			WHEN @EventName IN (
				SELECT TOP 1 e.EventName
				FROM tblEvent e
				ORDER BY e.EventName DESC
			)
				THEN 'Last alphabetically'

			WHEN @EventName IN (
				SELECT TOP 1 e.EventName
				FROM tblEvent e
				ORDER BY e.EventDate ASC
			)
				THEN 'Oldest'

			WHEN @EventName IN (
				SELECT TOP 1 e.EventName
				FROM tblEvent e
				ORDER BY e.EventDate DESC
			)
				THEN 'Newest'

			ELSE 'Not a winner'
		END

	RETURN @EventType

END

GO






SELECT
	e.EventName,
	dbo.fnEventWinner(e.EventName) AS [Winners]
FROM
	tblEvent e
ORDER BY
	[Winners]