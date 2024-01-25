USE Books
GO

ALTER PROC CreateGenreTable AS

SET NOCOUNT ON

-- delete the foreign key constraint if it exists
IF object_id('fk_author_genre','F') is not null 
	ALTER TABLE tblAuthor DROP CONSTRAINT fk_author_genre

-- delete the table of genres if it exists
IF object_id('tblGenre','U') is not null DROP TABLE tblGenre

-- if there's a column in the authors table called GenreId, delete that too
IF EXISTS (
	SELECT * FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'tblAuthor' AND COLUMN_NAME = 'GenreId'
)
	ALTER TABLE tblAuthor DROP COLUMN GenreId

-- create a new column in the author table to hold the genre id
ALTER TABLE tblAuthor ADD GenreId int Null

-- create a table of genres (id is the primary key, name can't be blank)
CREATE TABLE tblGenre(
	GenreId int IDENTITY(1,1) PRIMARY KEY,
	GenreName varchar(20) NOT NULL,
	Rating int
)

-- index the genre name for faster sorting
CREATE INDEX idx_tblGenre_GenreName ON tblGenre(GenreId)

-- create a few new genres
INSERT INTO tblGenre (GenreName, Rating) VALUES ('Romance', 3)
INSERT INTO tblGenre (GenreName, Rating) VALUES ('Science fiction', 7)
INSERT INTO tblGenre (GenreName, Rating) VALUES ('Thriller', 5)
INSERT INTO tblGenre (GenreName, Rating) VALUES ('Humour', 3)

-- make the authors belong to the right genre
UPDATE tblAuthor SET GenreId=3 WHERE AuthorId=1
UPDATE tblAuthor SET GenreId=2 WHERE AuthorId=2
UPDATE tblAuthor SET GenreId=1 WHERE AuthorId=3

-- create relationship between the tables
ALTER TABLE 
	tblAuthor
ADD CONSTRAINT
	fk_author_genre FOREIGN KEY (GenreId)
	REFERENCES tblGenre (GenreId)

	ON UPDATE CASCADE
	ON DELETE CASCADE

-- display the results
SELECT 
	a.FirstName + ' ' + a.LastName AS 'Author',
	g.GenreName as 'Genre'
FROM
	tblAuthor AS a
	INNER JOIN tblGenre AS g ON a.GenreId=g.GenreId


