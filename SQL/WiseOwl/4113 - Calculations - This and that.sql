--You should find the CHARINDEX function useful.  Here's an example:
--CHARINDEX( 'Trump', 'Donald Trump', 1)
--This would return 8, since Trump begins in Donald Trump at the 8th character (starting from 1).


SELECT 
	e.EventName,
	e.EventDate,
	CHARINDEX('this', e.EventDetails, 1) AS thisPosition,
	CHARINDEX('that', e.EventDetails, 1) AS thatPosition,
	CHARINDEX('that', e.EventDetails, 1) - CHARINDEX('this', e.EventDetails, 1) AS Offset
FROM
	WorldEvents.dbo.tblEvent e
WHERE
	CHARINDEX('this', e.EventDetails, 1) > 0
	AND CHARINDEX('that', e.EventDetails, 1) > 0
	AND CHARINDEX('that', e.EventDetails, 1) - CHARINDEX('this', e.EventDetails, 1) > 0