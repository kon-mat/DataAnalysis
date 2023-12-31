USE WorldEvents



SELECT
	Family.FamilyName,

	-- start with the top level, if there is one
	CASE
		WHEN TopFamily.FamilyName IS NULL THEN ''
		ELSE TopFamily.FamilyName + ' > '
	END +
	
	-- add on the next level, again if there is one
	CASE
		WHEN ParentFamily.FamilyName IS NULL THEN ''
		ELSE ParentFamily.FamilyName + ' > '
	END +

	-- there's always a bottom level
	Family.FamilyName

FROM
	-- start with the bottom level
	dbo.tblFamily Family

	-- use each family's parent to link to the next level up
	LEFT OUTER JOIN dbo.tblFamily ParentFamily
		ON Family.ParentFamilyId = ParentFamily.FamilyID

		-- repeat to get the "grandparent" family
	LEFT OUTER JOIN dbo.tblFamily TopFamily
		ON ParentFamily.ParentFamilyId = TopFamily.FamilyID

ORDER BY
	Family.FamilyName