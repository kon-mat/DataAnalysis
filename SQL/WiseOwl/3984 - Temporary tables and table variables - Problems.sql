USE DoctorWho
GO


IF object_id('tempdb.dbo.#Problems','U') is not null 
	DROP TABLE #Problems
	
CREATE TABLE #Problems (
	ProblemId int identity(1, 1) primary key
	, TableName varchar(100)
	, Id int
	, ColumnName varchar(100)
	, ColumnValue varchar(max)
	, ProblemName varchar(100)
)


INSERT INTO #Problems (
	TableName
	, Id
	, ColumnName
	, ColumnValue
	, ProblemName
)
SELECT
	'tblEnemy' as TableName
	, en.EnemyId as Id
	, 'Description' as ColumnName
	, en.Description as ColumnValue
	, 'Description has ' + cast(len(en.Description) as varchar) + ' letters' as ProblemName
FROM
	tblEnemy en
WHERE
	len(en.Description) > 75


INSERT INTO #Problems (
	TableName
	, Id
	, ColumnName
	, ColumnValue
	, ProblemName
)
SELECT
	'tblEpisode' as TableName
	, e.EpisodeId as Id
	, 'Notes' as ColumnName
	, e.Notes as ColumnValue
	, 'Notes field filled in' as ProblemName
FROM
	tblEpisode e
WHERE
	e.Notes is not null


SELECT * FROM #Problems