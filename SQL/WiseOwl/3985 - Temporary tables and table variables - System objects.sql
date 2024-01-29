USE DoctorWho
GO


-- show tables, views, etc in your database
--SELECT * FROM sys.objects

IF object_id('tempdb.dbo.#SystemObjects','U') is not null 
	DROP TABLE #SystemObjects

CREATE TABLE #SystemObjects (
	ObjectType varchar(100)
	, ObjectName varchar(100)
	, DateCreated date
)



INSERT INTO #SystemObjects (
	ObjectType
	, ObjectName
	, DateCreated
)
SELECT 
	'Stored procedure'
	, so.name
	, so.create_date
FROM 
	sys.objects so
WHERE 
	so.type = 'P'
	and so.name not like '%episodes%'


INSERT INTO #SystemObjects (
	ObjectType
	, ObjectName
	, DateCreated
)
SELECT 
	'Scalar function'
	, so.name
	, so.create_date
FROM 
	sys.objects so
WHERE 
	so.type = 'FN'


SELECT * FROM #SystemObjects