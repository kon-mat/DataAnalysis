CREATE FUNCTION fnSplitString (
  @String NVARCHAR(max),
  @Delimiter NVARCHAR(255),
	@ReturnIndex INT = 1
)
RETURNS NVARCHAR(MAX)
AS
	BEGIN
		
		-- Żeby otrzymać prawidłowy split musimy sprawdzić, czy ten separator nie występuje gdzieś w zbiorze danych
		DECLARE @Separator NVARCHAR(1) = '〞'
		DECLARE @StringWithSeparator NVARCHAR(MAX) = REPLACE(@String, @Delimiter, @Separator)

		RETURN (
			SELECT
				value
			FROM
				string_split(@StringWithSeparator, @Separator, 1)
			WHERE
				ordinal = @ReturnIndex
		)

	END
GO