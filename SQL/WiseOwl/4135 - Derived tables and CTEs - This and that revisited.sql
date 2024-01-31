USE WorldEvents
GO


WITH ThisThatEvent as (
	SELECT
		e.EventID
		, e.EventName
		, e.EventDetails
		, charindex('this', e.EventDetails, 1) as [ThisPosition]
		, charindex('that', e.EventDetails, 1) as [ThatPosition]
	FROM
		tblEvent e
)


SELECT
	tte.EventID
	, tte.EventName
	, tte.EventDetails
FROM
	ThisThatEvent tte
WHERE	
	tte.ThatPosition > 0
	and tte.ThisPosition > 0


