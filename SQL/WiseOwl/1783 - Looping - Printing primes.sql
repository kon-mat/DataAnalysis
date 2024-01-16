
DECLARE @Current INT			-- the current number whose primeness we're testing
DECLARE @Previous	INT			-- the number we're trying to divide into this

DECLARE @HighestFactor DECIMAL(10,4)	-- the highest possible factor of the number we're testing
DECLARE @HighestFactorInteger INT			-- the same thing, rounded down to the nearest integer
DECLARE @IfPrime BIT									-- whether the number we're testing is prime (1) or not (0)

-- see how long it takes
DECLARE @StartTime DATETIME
DECLARE @EndTime DATETIME

SET @StartTime = CURRENT_TIMESTAMP

-- start with 2, and work our way up!
SET @Current = 2
WHILE @Current < 50
	BEGIN

		-- assume that the number is prime to start with
		SET @IfPrime = 1

		-- work out what the highest possible factor could be (eg square root of 10 is 3.162, so
		-- the highest possible factor is 3)
		SET @HighestFactor = SQRT(@Current)
		SET @HighestFactorInteger = FLOOR(@HighestFactor)

		-- start with 2, and work our way up
		SET @Previous = 2
		WHILE @Previous <= @HighestFactorInteger
			BEGIN
				IF @Current % @Previous = 0
					BEGIN

						-- if dividing by this number leaves no remainder, then it wasn't a prime 
						-- (and there's no point testing if any other numbers this one)
						SET @IfPrime = 0
						BREAK
					END

				-- try the next factor
				SET @Previous = @Previous + 1

			END

			-- if this was prime, print it out
			IF @IfPrime = 1 PRINT CAST(@Current AS VARCHAR(10))

		-- try the next possible prime
		SET @Current = @Current + 1

	END

SET @EndTime = CURRENT_TIMESTAMP
PRINT 'Took ' + CAST(DATEDIFF(ms, @StartTime, @EndTime) AS VARCHAR(10)) + ' milliseconds'