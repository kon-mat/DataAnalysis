USE WorldEvents
GO


ALTER PROC spProcedure1 (
	@OutputParameter VARCHAR(100) = NULL OUTPUT
)
AS
SELECT TOP(1)
	@OutputParameter =  cnt.ContinentName
FROM	
	tblEvent e

	INNER JOIN tblCountry ctr
		ON e.CountryID = ctr.CountryID

	INNER JOIN tblContinent cnt
		ON ctr.ContinentID = cnt.ContinentID
	
ORDER BY
	e.EventDate ASC
GO


ALTER PROC spProcedure2 (
	@Parameter VARCHAR(100)
)
AS
SELECT
	cnt.ContinentName,
	e.EventName,
	e.EventDate
FROM	
	tblEvent e

	INNER JOIN tblCountry ctr
		ON e.CountryID = ctr.CountryID

	INNER JOIN tblContinent cnt
		ON ctr.ContinentID = cnt.ContinentID
	
WHERE
	@Parameter IS NULL
	OR cnt.ContinentName = @Parameter
ORDER BY
	e.EventDate ASC
GO


DECLARE @Variable VARCHAR(100) = ''

EXEC spProcedure1
@OutputParameter = @Variable OUTPUT

EXEC spProcedure2
@Parameter = @Variable
