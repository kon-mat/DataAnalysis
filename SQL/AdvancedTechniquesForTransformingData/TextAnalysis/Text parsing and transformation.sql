USE AdvancedTechniques
GO



--	-----[   PARSOWANIE TEKSTU   ]-----


--	1. Funkcja splitująca po ciągu znaków
ALTER FUNCTION fnSplitString (
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



--	2. Wykorzystanie funkcji splitującej dla różnych argumentów
SELECT

	dbo.fnSplitString(
		dbo.fnSplitString(
			dbo.fnSplitString(u.sighting_report, ' (Entered', 1),
			'Occurred : ', 2
		),
		'Reported', 1
	) AS [occurred],

	dbo.fnSplitString(
		dbo.fnSplitString(u.sighting_report, ')', 1),
		'Entered as : ', 2
	) AS [entered_as],

	dbo.fnSplitString(
		dbo.fnSplitString(
			dbo.fnSplitString(
				dbo.fnSplitString(u.sighting_report, 'Post', 1),
				'Reported: ', 2
			),
			' AM', 1
		),
		' PM', 1
	) AS [reported],

	dbo.fnSplitString(
		dbo.fnSplitString(u.sighting_report, 'Location', 1),
		'Posted: ', 2
	) AS [posted],
	
	dbo.fnSplitString(
		dbo.fnSplitString(u.sighting_report, 'Shape', 1),
		'Location: ', 2
	) AS [location],

	dbo.fnSplitString(
		dbo.fnSplitString(u.sighting_report, 'Duration', 1),
		'Shape: ', 2
	) AS [shape],

	dbo.fnSplitString(u.sighting_report, 'Duration:', 2) AS [duration]

FROM
	ufo u


--		OUTPUT:
--occurred				entered_as				reported						posted			location										shape				duration
--1/1/2008 00:40	01/01/08 00:40		1/1/2008 9:08:23		1/21/2008		La Jolla, CA								Light				5 minutes
--1/1/2008 00:45	01/01/08 00:45		1/2/2008 6:50:39		1/21/2008		Puerto Escodido (Mexico), 	Sphere			3-4 min
--1/1/2008 01:00	01/01/08 1:00			1/1/2008 4:00:17		1/21/2008		Citrus Heights, CA					Formation		10 min.
--1/1/2011 00:11	01/01/11 0:11			12/31/2010 10:20:19	1/5/2011		Bradenton, FL								Triangle		1 min. 30 sec
--1/1/2011 00:13	01/01/2011 0:13		1/3/2011 9:01:33		1/5/2011		Oak Lawn, IL								Fireball		20 seconds
--1/1/2011 00:15	01/01/2011 12:15	12/31/2010 11:27:31	1/5/2011		Katy, TX										Sphere			30 seconds
--1/1/2011 00:15	01012011 00:15		1/7/2011 11:02:04		1/31/2011		Milmont Park, PA						Triangle		10 minutes



--	-----[   PRZEKSZTAŁCANIEE TEKSTU   ]-----


--	1. Zmiana typów danych
SELECT TOP 20

	CASE
		WHEN u2.occurred IS NULL OR u2.occurred = ''
			THEN NULL
		WHEN LEN(u2.occurred) < 8
			THEN NULL
		ELSE
			CAST(u2.occurred AS datetime)
	END AS [occured],

	CASE
		WHEN u2.reported IS NULL OR u2.reported = ''
			THEN NULL
		WHEN LEN(u2.reported) < 8
			THEN NULL
		ELSE
			CAST(u2.reported AS datetime)
	END AS [reported],

	CASE
		WHEN u2.posted IS NULL OR u2.posted = ''
			THEN NULL
		ELSE
			CAST(u2.posted AS date)
	END AS [posted]

FROM
(
	SELECT
		dbo.fnSplitString(
			dbo.fnSplitString(
				dbo.fnSplitString(u.sighting_report, ' (Entered', 1),
				'Occurred : ', 2
			),
			'Reported', 1
		) AS [occurred],

		dbo.fnSplitString(
			dbo.fnSplitString(
				dbo.fnSplitString(
					dbo.fnSplitString(u.sighting_report, 'Post', 1),
					'Reported: ', 2
				),
				' AM', 1
			),
			' PM', 1
		) AS [reported],

		dbo.fnSplitString(
			dbo.fnSplitString(u.sighting_report, 'Location', 1),
			'Posted: ', 2
		) AS [posted]

	FROM
		ufo u
) u2