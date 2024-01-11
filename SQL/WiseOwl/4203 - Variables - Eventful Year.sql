USE WorldEvents
GO


DECLARE @YearOfBirth INT = 1990

-- Important to declare empty string (not null!)
DECLARE @EventfulYear VARCHAR(255) = ''

SELECT

	-- 1st version (shorter)
	@EventfulYear = @EventfulYear + e.EventName + ', '

	-- 2nd version
	--@EventfulYear = @EventfulYear +
	--	CASE
	--		WHEN LEN(@EventfulYear) > 0 THEN ', '
	--		ELSE ''
	--	END + e.EventName

FROM
	tblEvent e
WHERE
	e.EventDate BETWEEN DATEFROMPARTS(@YearOfBirth, 1, 1) 
		AND DATEFROMPARTS(@YearOfBirth, 12, 31)


SELECT
	@EventfulYear AS [Eventful Year]