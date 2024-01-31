USE Carnival
GO

WITH menus AS ( 

	-- get the first row (ie the menu whose parent 
	-- is null)
	SELECT 
		MenuId,
		MenuName,
		CAST('Top' AS varchar(100)) AS Breadcrumb
	FROM 
		tblMenu
	WHERE 
		ParentMenuId  IS NULL 
	
	-- link to all of those rows whose parent menu
	-- id equals this row's menu id
	UNION ALL 
 
	SELECT 
		submenus.MenuId,
		submenus.MenuName,
		CAST((m.Breadcrumb + ' > ' + m.MenuName)
			AS varchar(100)) AS Breadcrumb
	FROM 
		tblMenu AS submenus
		INNER JOIN menus AS m
			ON submenus.ParentMenuId=m.MenuId
	) 

-- show the results (avoid infinite recursion possibility)
SELECT * FROM menus OPTION (MAXRECURSION 2)
