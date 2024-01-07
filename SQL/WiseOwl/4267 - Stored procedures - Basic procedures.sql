USE WorldEvents
GO


CREATE PROC uspCountriesContinent @ContinentID INT
AS
	SELECT 
		c.CountryID,
		c.CountryName
	FROM
		tblCountry c
	WHERE 
		c.ContinentID = @ContinentID
	ORDER BY
		c.CountryName
GO


EXEC uspCountriesContinent @ContinentID = 3