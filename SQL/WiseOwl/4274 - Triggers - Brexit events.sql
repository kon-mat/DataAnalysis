USE WorldEvents
GO



ALTER TRIGGER trgEventMonitor
ON tblEvent
INSTEAD OF DELETE
AS
BEGIN

	-- don't let anyone delete an event
	DECLARE @CountryId int
	DECLARE @EventId int

	SELECT 
		@CountryId = d.CountryID,
		@EventId = D.EventID
	FROM 
		deleted AS d

	-- if country is not UK (7), allow deletion
	IF @CountryId <> 7 
		BEGIN
			DELETE 
			FROM tblEvent
			WHERE EventId = @EventId
		END

END