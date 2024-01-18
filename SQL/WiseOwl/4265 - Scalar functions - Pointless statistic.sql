USE WorldEvents
GO

ALTER FUNCTION fnLetterCount (
	@EventName VARCHAR(MAX),
	@EventDetails VARCHAR(MAX)
)
RETURNS INT
AS

BEGIN

	RETURN LEN(@EventName) + LEN(@EventDetails)

END
GO



SELECT
	e.EventName,
	e.EventDetails,
	e.EventDate,
	dbo.fnLetterCount(e.EventName, e.EventDetails) AS [Total letters]
FROM
	tblEvent e
ORDER BY
	[Total letters] ASC