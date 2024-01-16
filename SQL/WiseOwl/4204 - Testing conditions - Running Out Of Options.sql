USE WorldEvents
GO


ALTER PROC spInformation (
	@Information VARCHAR(MAX)
)
AS


IF @Information = 'Country' -- Consider using '%' + @Information + '%' to account for variances in what is entered
	BEGIN -- IF is a true false or boolean test. If the test returns true SQL will run the very next command, if false the next command is skiped. BEGIN END allows multiple commands to be triggered or skipped.
		SELECT top 2
			CountryName
		FROM
			tblCountry
	--RETURN would exit the script and prevent @Information being tested further if it's value was 'Country'
	END

IF @Information = 'Event'
	BEGIN
		SELECT
			e.EventName,
			e.EventDetails,
			e.EventDetails
		FROM
			tblEvent e
	END

IF @Information = 'Continent'
	BEGIN
		SELECT
			cnt.ContinentName
		FROM
			tblContinent cnt
	END
	--ELSE can be paired with the previous IF. The ELSE is only triggered when the corresponding IF returns FALSE.

IF @Information NOT IN ('Country', 'Event', 'Continent')
	BEGIN
		SELECT
			'You must enter: Event, Country or Continent' AS [Nuh uh say the magic word]
	END

GO




--Try the stored procedure with each of the possible outcomes.
EXEC spInformation 'Event'  

EXEC spInformation 'Country'

EXEC spInformation 'Continent'

EXEC spInformation 'Something else'