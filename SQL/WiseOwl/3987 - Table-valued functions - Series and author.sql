USE DoctorWho
GO


ALTER FUNCTION dbo.fnChosenEpisodes (
	@SeriesNumber int
	, @AuthorName varchar(100)
)
RETURNS TABLE
AS


RETURN
	SELECT
		e.Title
		, a.AuthorName
		, d.DoctorName
	FROM
		tblEpisode e
		INNER JOIN tblAuthor a on e.AuthorId = a.AuthorId
		INNER JOIN tblDoctor d on e.DoctorId = d.DoctorId
	WHERE
		(@SeriesNumber is null
		or e.SeriesNumber = @SeriesNumber) 
		and 
		(@AuthorName is null
		or a.AuthorName like '%' + @AuthorName + '%')
GO



-- there is 1 episode written by Steven Moffat for series 2
SELECT COUNT(*) FROM dbo.fnChosenEpisodes(2,'moffat')

-- -- there are 14 episodes in series 2 (for any author)
SELECT COUNT(*) FROM dbo.fnChosenEpisodes(2,null)

-- there are 32 episodes written by Steven Moffat (for any series)
SELECT COUNT(*) FROM dbo.fnChosenEpisodes(null,'moffat')

-- there are 117 episodes (any series, any author)
SELECT COUNT(*) FROM dbo.fnChosenEpisodes(null,null)