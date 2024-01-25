USE Books
GO

SET NOCOUNT ON


-- delete the table if it exists
IF object_id('tblGenre', 'U') is not null DROP TABLE tblGenre

-- create a table of genres (id is the primary key, name can't be blank)
CREATE TABLE tblGenre (
	GenreId int identity(1, 1) primary key 	-- autoincrement +1 starting from 1
	, GenreName varchar(20) not null
	, Rating int
)

-- index the genre name for faster sorting
CREATE INDEX idx_tblGenre_GenreName ON tblGenre(GenreId)

-- create a few new genres
INSERT INTO 
	tblGenre (GenreName, Rating)
VALUES 
	('Romance', 3)
	, ('Science fiction', 7)
	, ('Thriller', 5)
	, ('Humour', 3)
	
-- show id of last one added
PRINT ''
PRINT 'Last one added was number ' + CAST(@@IDENTITY AS varchar(5))	-- @@IDENTITY - Is a system function that returns the last-inserted identity value.
PRINT ''

-- show all records added
SELECT * FROM tblGenre