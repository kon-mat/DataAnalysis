USE WorldEvents
GO


ALTER PROC spHowMuchLonger
AS

DECLARE @Diffrence INT = (
	SELECT
		MAX(LEN(e.EventName)) - MIN(LEN(e.EventName))
	FROM
		tblEvent e
)

RETURN @Diffrence
GO

DECLARE @VariableName INT
EXEC @VariableName = spHowMuchLonger

SELECT
	'The diffrence between the longest film name and the shortest is: ' +
		CAST(@VariableName AS VARCHAR(100)) + ' characters'
		AS [How much longer?]