--SELECT coalesce(NULL, 1, NULL);
--Zwraca pierwszy argument inny ni¿ null - 1

SELECT
	c.ContinentName,
	c.Summary,
	ISNULL(c.Summary, 'No summary') AS 'Using ISNULL',
	COALESCE(c.Summary, 'No summary') AS 'Using COALESCE',
	CASE
		WHEN c.Summary IS NULL THEN
			'No summary'
		ELSE
			c.Summary
	END AS 'Using CASE'
FROM
	WorldEvents.dbo.tblContinent c