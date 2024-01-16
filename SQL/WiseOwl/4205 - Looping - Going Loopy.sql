-- create the counter, normally a variable
DECLARE @Counter INT = 1980

-- create an end point to stop the loop
DECLARE @EndValue INT = YEAR(CURRENT_TIMESTAMP)

-- start the loop and set an end point

WHILE @Counter <= @EndValue
	BEGIN
		
		DECLARE @NumberOfEvents INT = (
			SELECT TOP 1
				COUNT(e.EventID) OVER (
					PARTITION BY YEAR(e.EventDate)
				)
			FROM
				tblEvent e
			WHERE
				YEAR(e.EventDate) = @Counter
		)
		
		IF @NumberOfEvents IS NULL
			PRINT 'No events occurred in ' + CAST(@Counter AS VARCHAR(4))
		ELSE
			PRINT CAST(@NumberOfEvents AS VARCHAR(4)) +
				' event occurred in ' + CAST(@Counter AS VARCHAR(4))

		 --Increase the counter
		SET @Counter = @Counter + 1

	END

