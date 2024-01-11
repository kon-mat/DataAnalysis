
DECLARE @Variable1 VARCHAR(50) = 'Jan Kowalski'
DECLARE @Variable2 DATETIME = '1990-10-10'
DECLARE @Variable3 INT = 5

PRINT 'My name is ' + @Variable1 + 
	', I was born on ' + FORMAT(@Variable2, 'dd.MM.yyyy') 
	+ ' and I have ' + CAST(@Variable3 AS VARCHAR(3)) + ' pets'