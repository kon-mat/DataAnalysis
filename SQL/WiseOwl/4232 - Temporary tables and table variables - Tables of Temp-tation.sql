USE WorldEvents
GO

IF object_id('tempdb.dbo.#EventsByLetter', 'U') is not null
	DROP TABLE #EventsByLetter

CREATE TABLE #EventsByLetter (
	[First letter] varchar(2)
	, [Number of events] int
)


INSERT INTO #EventsByLetter (
	[First letter]
	, [Number of events]
)
SELECT
	left(e.EventName, 1)
	, count(*)
FROM
	tblEvent e
GROUP BY
	left(e.EventName, 1)


SELECT * 
FROM #EventsByLetter
ORDER BY [First letter]
