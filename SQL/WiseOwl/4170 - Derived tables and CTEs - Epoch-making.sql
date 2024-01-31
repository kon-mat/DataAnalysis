USE WorldEvents
GO


WITH EventsByEra as (
	SELECT
		case
			when year(e.EventDate) < 1900 then '19th century and earlier'
			when year(e.EventDate) < 2000 then '20th century'
			else '21th century'
		end as Era
		, e.EventID
	FROM
		tblEvent e
)

SELECT
	ebe.Era
	, count(distinct ebe.EventID) as [Number of events]
FROM
	EventsByEra ebe
GROUP BY
	ebe.Era
