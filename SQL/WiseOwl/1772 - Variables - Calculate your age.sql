USE WorldEvents
GO

CREATE PROC spCalculateAge
AS

-- declare variable to hold your age
DECLARE @Age INT

-- calculate how old you are
SET @Age = DATEDIFF(YEAR, '1994-10-10', GETDATE())

-- print out your age
PRINT 'You are ' + CAST(@Age AS VARCHAR(5)) + ' years old'




EXEC spCalculateAge