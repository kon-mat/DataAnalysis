USE WorldEvents
GO


CREATE PROC uspAugustEvents
AS
	SELECT
		TOP(5) e.EventID,
		e.EventName,
		e.EventDetails,
		e.EventDate
	FROM
		tblEvent e
	WHERE
		DATEPART(month, e.EventDate) = 8
GO


EXEC uspAugustEvents