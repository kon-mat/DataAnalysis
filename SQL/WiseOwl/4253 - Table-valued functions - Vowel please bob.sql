USE WorldEvents
GO


ALTER FUNCTION fnVowellyThings (
	@vowel char(1)
)
RETURNS @t TABLE (
	EntityName varchar(max)
)
AS
BEGIN

	-- add categories
	INSERT INTO @t (
		EntityName
	)
	SELECT 
		c.CategoryName
	FROM
		tblCategory AS c
	WHERE
		c.CategoryName like '%' + @vowel + '%'

	-- add countries
	INSERT INTO @t (
		EntityName
	)
	SELECT 
		c.ContinentName
	FROM
		tblContinent AS c
	WHERE
		c.ContinentName like '%' + @vowel + '%'

	-- add categories
	INSERT INTO @t (
		EntityName
	)
	SELECT 
		c.CountryName
	FROM
		tblCountry AS c
	WHERE
		c.CountryName like '%' + @vowel + '%'

	RETURN
END
GO

-- show results
SELECT 
	(SELECT count(*) FROM dbo.fnVowellyThings('a')) AS A_results,
	(SELECT count(*) FROM dbo.fnVowellyThings('e')) AS E_results,
	(SELECT count(*) FROM dbo.fnVowellyThings('i')) AS I_results,
	(SELECT count(*) FROM dbo.fnVowellyThings('o')) AS O_results,
	(SELECT count(*) FROM dbo.fnVowellyThings('u')) AS U_results