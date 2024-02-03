USE WorldEvents
GO


-- table to hold changes made
CREATE TABLE tblCountryChanges(
	CountryName varchar(100),
	Change varchar(100)
)

GO

-- trigger to capture previous and new country name
CREATE TRIGGER trgCountryUpdate
ON tblCountry
AFTER UPDATE
AS

BEGIN

	-- capture previous name
	INSERT INTO tblCountryChanges(
		CountryName,
		Change
	)
	SELECT d.CountryName, 'Previous name'
	FROM deleted AS d

	-- get new name
	INSERT INTO tblCountryChanges(
		CountryName,
		Change
	)
	SELECT i.CountryName, 'New name'
	FROM inserted AS i

END
GO

-- now create trigger to cope with country deletion
CREATE TRIGGER trgCountryDelete
ON tblCountry
AFTER DELETE
AS
BEGIN

	-- store deleted country
	INSERT INTO tblCountryChanges(
		CountryName,
		Change
	)
	SELECT d.CountryName, 'Deleted'
	FROM deleted AS d

END
GO

-- finally create trigger to cope with country insertion
CREATE TRIGGER trgCountryInsert
ON tblCountry
AFTER INSERT
AS
BEGIN

	-- store inserted country
	INSERT INTO tblCountryChanges(
		CountryName,
		Change
	)
	SELECT i.CountryName, 'Inserted'
	FROM inserted AS i

END