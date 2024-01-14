USE WorldEvents
GO


ALTER PROC spMostNumerous (
	@TopCountry VARCHAR(100) = NULL OUTPUT,	--Putting a default value means SQL won't ask for a value to be passed in
	@EventCount INT = NULL OUTPUT	-- OUTPUT tells SQL you will be passing a value out
)
AS

SELECT TOP(1)
	@TopCountry = c.CountryName,
	@EventCount = COUNT(DISTINCT e.EventID)
FROM
	tblEvent e

	INNER JOIN tblCountry c
		ON e.CountryID = c.CountryID

GROUP BY
	c.CountryName
ORDER BY
	COUNT(DISTINCT e.EventID) DESC
GO


DECLARE @CountryVariable VARCHAR(250) --To hold the output parameters
DECLARE @EventCountVariable INT

EXEC spMostNumerous
@TopCountry = @CountryVariable OUTPUT, --It looks like you would be passing the value from the variable into the parameter. Normally this is the case.
@EventCount = @EventCountVariable OUTPUT --However using OUTPUT changes the direction of data pass. So this is passing a value from parameter to the variable.

--Select both variables to prove you have captured the valyes in the output parameters
SELECT
	@CountryVariable AS [Country of interest], 
	@EventCountVariable AS [Number of events] --Select both variables to prove you have captured the valyes in the output parameters

