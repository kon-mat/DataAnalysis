USE WorldEvents
GO


DECLARE @MonthCounter INT = 1

WHILE @MonthCounter <= 12
	BEGIN
		
		DECLARE @EventList VARCHAR(MAX) = ''

		SELECT
			@EventList = @EventList + 
				CASE
					WHEN LEN(@EventList) > 0 THEN ', '
					ELSE ''
				END + e.EventName
		FROM
			tblEvent e
		WHERE
			MONTH(e.EventDate) = @MonthCounter

		PRINT 'Events which occurred in ' +
			DATENAME(MM, '2017-' + CAST(@MonthCounter AS VARCHAR(2)) + '-01') + 
			': ' + @EventList

		SET @MonthCounter = @MonthCounter + 1

	END












