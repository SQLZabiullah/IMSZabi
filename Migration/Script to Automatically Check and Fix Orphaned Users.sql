--USE [YourDatabaseName];
--GO

DECLARE @OrphanedUser NVARCHAR(128);

-- Cursor to iterate through orphaned users
DECLARE orphaned_users_cursor CURSOR FOR
SELECT dp.name AS OrphanedUser
FROM sys.database_principals dp
LEFT JOIN sys.server_principals sp ON dp.sid = sp.sid
WHERE dp.type_desc = 'SQL_USER'
AND sp.sid IS NULL;

OPEN orphaned_users_cursor;
FETCH NEXT FROM orphaned_users_cursor INTO @OrphanedUser;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Check if a login with the same name exists
    IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @OrphanedUser)
    BEGIN
        -- Map the orphaned user to the existing login
        EXEC sp_change_users_login 'Auto_Fix', @OrphanedUser;
        PRINT 'Mapped orphaned user ' + @OrphanedUser + ' to existing login.';
    END
    ELSE
    BEGIN
        -- Create a new login and map the orphaned user to it
        DECLARE @sql NVARCHAR(MAX) = 'CREATE LOGIN [' + @OrphanedUser + '] WITH PASSWORD = ''YourStrongPassword'';';
        EXEC sp_executesql @sql;
        
        SET @sql = 'ALTER USER [' + @OrphanedUser + '] WITH LOGIN = [' + @OrphanedUser + '];';
        EXEC sp_executesql @sql;

        PRINT 'Created new login and mapped orphaned user ' + @OrphanedUser + '.';
    END

    FETCH NEXT FROM orphaned_users_cursor INTO @OrphanedUser;
END;

CLOSE orphaned_users_cursor;
DEALLOCATE orphaned_users_cursor;