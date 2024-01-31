USE WorldEvents
GO


WITH ThisAndThat as (
	SELECT
		case
			when charindex('This', e.EventDetails, 1) > 0 then 1
			else 0
		end as IfThis
		, case
			when charindex('That', e.EventDetails, 1) > 0 then 1
			else 0
		end as IfThat
		, count(distinct e.EventID) as [Number of events]
	FROM
		tblEvent e
	GROUP BY
		case
			when charindex('This', e.EventDetails, 1) > 0 then 1
			else 0
		end
		, case
			when charindex('That', e.EventDetails, 1) > 0 then 1
			else 0
		end
)

, BothThisAndThat as (
	SELECT
		e.EventName
		, e.EventDetails
	FROM
		tblEvent e
	WHERE
		case
			when charindex('This', e.EventDetails, 1) > 0 then 1
			else 0
		end = 1
		and case
			when charindex('That', e.EventDetails, 1) > 0 then 1
			else 0
		end = 1
)


--SELECT * FROM ThisAndThat

SELECT * FROM BothThisAndThat