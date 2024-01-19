USE WorldEvents
GO

BEGIN TRANSACTION DoesEventExist


--Count how many events have My DOB, if it's not zero undo the transaction
IF (
		SELECT
			COUNT(*)
		FROM
			dbo.tblEvent e
		WHERE
			e.EventName LIKE 'My DOB'
	) <> 0
	BEGIN

		ROLLBACK TRANSACTION DoesEventExist
		SELECT 
			'This magnificent event already exists' AS EventResults --If it exists we give a message telling us this and rollback the tran

	END
ELSE
	BEGIN

		INSERT INTO tblEvent (
			EventName,
			EventDetails,
			EventDate
		) --Add the new event
		VALUES (
			'My DOB', 
			'I was born and the world trembles', 
			'1991-04-26'
		)

		COMMIT TRAN DoesEventExist
		SELECT 
			'This momentous event has now been added' AS EventResults --Commit the changes and tell the world

	END


SELECT TOP 1 
	* 
FROM 
	tblEvent 
ORDER BY
	eventid DESC --Either way select the pre-existing or newly created event



DELETE FROM tblEvent WHERE EventName LIKE 'My DOB'


