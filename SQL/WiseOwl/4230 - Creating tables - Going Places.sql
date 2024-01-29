USE WorldEvents
GO


IF object_id('Summary_Data','U') is not null DROP TABLE Summary_Data

CREATE TABLE Summary_Data (
	SummaryItem varchar(50)
	, CountEvents int
)

-- Insert millenium events count into Summary_Data table
INSERT INTO 
	Summary_Data
SELECT
	case
		when year(e.EventDate) >= 2000 then 'This Millenium'
		when year(e.EventDate) between 1000 and 2000 then 'Last Millenium'
		else 'Other Millenium'
	end as [SummaryItem]
	, count(distinct e.EventID) as [CountEvents]
FROM
	tblEvent e
GROUP BY
	case
		when year(e.EventDate) >= 2000 then 'This Millenium'
		when year(e.EventDate) between 1000 and 2000 then 'Last Millenium'
		else 'Other Millenium'
	end


-- Insert country events count into Summary_Data table
INSERT INTO 
	Summary_Data
SELECT
	c.CountryName as [SummaryItem]
	, count(distinct e.EventID) as [CountEvents]
FROM
	tblEvent e
	INNER JOIN tblCountry c on e.CountryID = c.CountryID
GROUP BY
	c.CountryName


-- Insert continent events count into Summary_Data table
INSERT INTO 
	Summary_Data
SELECT
	cnt.ContinentName as [SummaryItem]
	, count(distinct e.EventID) as [CountEvents]
FROM
	tblEvent e
	INNER JOIN tblCountry ctr on e.CountryID = ctr.CountryID
	INNER JOIN tblContinent cnt on ctr.ContinentID = cnt.ContinentID
GROUP BY
	cnt.ContinentName


SELECT * FROM	Summary_Data
