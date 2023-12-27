
SELECT
	e.EventName,

	CASE

		-- this would show events beginning and ending with the same letter, where this is also a vowel
		WHEN CHARINDEX(left(e.EventName, 1), 'aeiou', 1) > 0
		AND left(e.EventName, 1) = right(e.EventName, 1) THEN
			'Same vowel'

		-- ones where the left and right letter are the same
		WHEN left(e.EventName, 1) = right(e.EventName, 1) THEN
			'Same letter'

		-- ones where both left and right letters are in the string of vowels
		WHEN CHARINDEX(left(e.EventName, 1), 'aeiou', 1) > 0
		AND CHARINDEX(right(e.EventName, 1), 'aeiou', 1) > 0 THEN
			'Begins and ends with vowel'

		-- the rest!
		ELSE 
			'Boring event!'

	END AS Verdict

FROM
	WorldEvents.dbo.tblEvent e
WHERE
	
	-- omit the boring ones
	CASE
		WHEN left(e.EventName, 1) = right(e.EventName, 1) THEN
			'Same letter'
		WHEN CHARINDEX(left(e.EventName, 1), 'aeiou', 1) > 0
		AND CHARINDEX(right(e.EventName, 1), 'aeiou', 1) > 0 THEN
			'Begins and ends with vowel'
		ELSE
			'Boring event!'
	END != 'Boring event!'

ORDER BY
	e.EventDate ASC