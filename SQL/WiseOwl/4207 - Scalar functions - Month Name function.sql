USE DoctorWho
GO


ALTER FUNCTION fnMonthName (
	@MonthNumber INT
)
RETURNS VARCHAR(100)
AS

BEGIN

	DECLARE @MonthName VARCHAR(100)
	
	IF (@MonthNumber < 1 OR @MonthNumber > 12)
		SET @MonthName = 'Month number out of range'
	ELSE
		SET @MonthName =  DATENAME(MM, '2000-' + CAST(@MonthNumber AS VARCHAR(2)) + '-01')

	RETURN @MonthName

END

GO



DECLARE @NumberOfMonths INT = 1

WHILE @NumberOfMonths <= 13
	BEGIN
		PRINT dbo.fnMonthName(@NumberOfMonths)
		SET @NumberOfMonths = @NumberOfMonths + 1
	END

