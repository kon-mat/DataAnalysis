USE DoctorWho
GO


-- create a table variable
DECLARE @characters TABLE (
	CharacterId int
	, CharacterName varchar(50)
	, CharacterType varchar(50)
)


-- add doctors into variable
INSERT INTO @characters(
	CharacterId
	, CharacterName
	, CharacterType
) 
SELECT
	DoctorId
	, DoctorName
	, 'Doctor'
FROM
	tblDoctor


-- now add the companions into this
INSERT INTO @characters(
	CharacterId
	, CharacterName
	, CharacterType
) 
SELECT
	CompanionId,
	CompanionName,
	'Companion'
FROM
	tblCompanion


-- finally add the enemies
INSERT INTO @characters(
	CharacterId
	, CharacterName
	, CharacterType
) 
SELECT
	EnemyId,
	EnemyName,
	'Enemy'
FROM
	tblEnemy


-- show results
SELECT * FROM @characters
ORDER BY CharacterName DESC