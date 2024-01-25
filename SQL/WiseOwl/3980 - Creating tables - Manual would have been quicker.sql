USE DoctorWho
GO


-- delete the table if it exists
IF object_id('tblProductionCompany','U') is not null DROP TABLE tblGenre

-- create new table to hold rows
CREATE TABLE tblProductionCompany (
	ProductionCompanyId int identity(1, 1) primary key
	, ProductionCompanyName varchar(50)
	, Abbreviation varchar(5)
)

INSERT INTO 
	tblProductionCompany (ProductionCompanyName, Abbreviation)
VALUES
	('British Broadcasting Corporation', 'BBC'),
	('Canadian Broadcasting Corporation', 'CBC')

SELECT * FROM tblProductionCompany