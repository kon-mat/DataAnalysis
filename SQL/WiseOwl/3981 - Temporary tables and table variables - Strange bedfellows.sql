USE DoctorWho
GO


IF object_id('tempdb.dbo.#Characters','U') is not null 
	DROP TABLE #Characters


-- create a table of the main characters in Doctor Who, using a table variable
SELECT
	DoctorId as CharacterId,
	DoctorName as CharacterName,
	CAST('Doctor' as varchar(10)) as CharacterType
INTO
	#Characters
FROM
	tblDoctor


-- allow more identity values to be inserted
SET IDENTITY_INSERT #Characters ON


-- now add the companions into this
INSERT INTO #Characters(
	CharacterId,
	CharacterName,
	CharacterType
) 
SELECT
	CompanionId,
	CompanionName,
	'Companion'
FROM
	tblCompanion


-- finally add the enemies
INSERT INTO #Characters(
	CharacterId,
	CharacterName,
	CharacterType
) 
SELECT
	EnemyId,
	EnemyName,
	'Enemy'
FROM
	tblEnemy


SET IDENTITY_INSERT #Characters OFF

-- show results
SELECT * FROM #Characters 
ORDER BY CharacterName DESC



