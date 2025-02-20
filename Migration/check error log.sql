-- Script to make the database readonly
USE [master]
GO
ALTER DATABASE [DBName] SET  READ_ONLY WITH NO_WAIT
GO
ALTER DATABASE [DBName] SET  READ_ONLY 
GO
-- Script to take the database offline
EXEC sp_dboption N'DBName', N'offline', N'true'
OR
ALTER DATABASE [DBName] SET OFFLINE WITH
ROLLBACK IMMEDIATE
