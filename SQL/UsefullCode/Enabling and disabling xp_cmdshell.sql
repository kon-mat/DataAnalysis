---- this turns on advanced options and is needed to configure xp_cmdshell
--EXEC sp_configure 'show advanced options', '1'
--RECONFIGURE
---- this enables xp_cmdshell
--EXEC sp_configure 'xp_cmdshell', '1' 
--RECONFIGURE


-- this turns on advanced options and is needed to configure xp_cmdshell
--EXEC sp_configure 'show advanced options', '1'
--RECONFIGURE
---- this disables xp_cmdshell
--EXEC sp_configure 'xp_cmdshell', '0' 
--RECONFIGURE