
SELECT
	e.EventName,
	e.EventDate AS NotFormatted,

	-- formatted using FORMAT function
	FORMAT(e.EventDate, 'dd/MM/yyyy') AS UsingFormat,

	-- formatted using CONVERT function
	CONVERT(char(10),e.EventDate,103) AS UsingConvert

FROM
	tblEvent AS e
WHERE
	-- only show events in 1978
	year(e.EventDate) = 1978
ORDER BY	
	e.EventDate