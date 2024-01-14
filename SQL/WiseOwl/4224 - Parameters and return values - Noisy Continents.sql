USE WorldEvents
GO

ALTER PROC spContinentsWith50Events (
	@ContinentList VARCHAR(MAX) = '' OUTPUT
)
AS


SELECT
	@ContinentList += cnt.ContinentName + ', '
FROM
	tblEvent e

	INNER JOIN tblCountry ctr
		ON e.CountryID = ctr.CountryID

	INNER JOIN tblContinent cnt
		ON ctr.ContinentID = cnt.ContinentID

GROUP BY
	ContinentName
HAVING
	COUNT(e.EventID) > 50
GO



DECLARE @ListOfContinents VARCHAR(MAX) = ''  -- Store the outputted list variable in a new variable.

EXEC spContinentsWith50Events 
	@ContinentList = @ListOfContinents OUTPUT

SELECT 
	LEFT(@ListOfContinents, LEN(@ListOfContinents)-1) AS [Big happenings] -- Remove that pesky trailing comma
