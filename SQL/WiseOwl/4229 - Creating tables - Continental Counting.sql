USE WorldEvents
GO


IF object_id('Continent_Summary','U') is not null DROP TABLE Continent_Summary

CREATE TABLE Continent_Summary (
	ContinentName varchar(50)
	, [Countries in continent] int
	, [Events in continent] int
	, [Earliest continent event] date
	, [Latest continent event] date
)

INSERT INTO
	Continent_Summary
SELECT 
	cnt.ContinentName
	, count(distinct ctr.CountryID) as [Countries in continent]
	, count(distinct e.EventID) as [Events in continent] 
	, min(e.EventDate) as [Earliest continent event] 
	, max(e.EventDate) as [Latest continent event] 
FROM
	tblEvent e
	INNER JOIN tblCountry ctr on e.CountryID = ctr.CountryID
	INNER JOIN tblContinent cnt on ctr.ContinentID = cnt.ContinentID
GROUP BY
	cnt.ContinentName


SELECT * FROM Continent_Summary

