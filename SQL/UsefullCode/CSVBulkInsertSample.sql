USE AdvancedTechniques
GO

CREATE TABLE earthquakes (
	time datetime2
	,latitude float
	,longitude float
	,depth float
	,mag float
	,magType nvarchar(255)
	,nst float
	,gap float
	,dmin float
	,rms float
	,net nvarchar(255)
	,id nvarchar(255)
	,updated datetime2
	,place nvarchar(255)
	,type nvarchar(255)
	,horizontalError float
	,depthError float
	,magError float
	,magNst float
	,status nvarchar(255)
	,locationSource nvarchar(255)
	,magSource nvarchar(255)
)

BULK INSERT earthquakes
FROM 'D:\earthquakes\earthquakes15.csv'
WITH (FORMAT = 'CSV'
				, FIRSTROW = 2
				, FIELDTERMINATOR = ','
				, ROWTERMINATOR = '0x0a');


SELECT * FROM earthquakes