DECLARE @name NVARCHAR(50)        -- Database name
DECLARE @backupPath NVARCHAR(256) -- Backup file path
DECLARE @backupFile NVARCHAR(256) -- Backup file name
DECLARE @sql NVARCHAR(500)        -- Backup command
DECLARE @verifySql NVARCHAR(500)  -- Verify command

-- Specify the backup directory
SET @backupPath = 'C:\Backups\' -- Replace with your backup directory

-- Cursor to iterate through all user databases
DECLARE db_cursor CURSOR FOR
SELECT name
FROM master.sys.databases
WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb') -- Exclude system databases

OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @name

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Construct the backup file name
    SET @backupFile = @backupPath + @name + '_COPY_ONLY_' + CONVERT(VARCHAR(20), GETDATE(), 112) + '.bak'

    -- Construct the backup command
    SET @sql = 'BACKUP DATABASE [' + @name + '] TO DISK = ''' + @backupFile + ''' WITH COPY_ONLY, INIT'

    -- Execute the backup command
    EXEC sp_executesql @sql

    -- Construct the verify command
    SET @verifySql = 'RESTORE VERIFYONLY FROM DISK = ''' + @backupFile + ''''

    -- Execute the verify command
    EXEC sp_executesql @verifySql

    -- Print the commands for verification
    PRINT 'Backup command: ' + @sql
    PRINT 'Verify command: ' + @verifySql

    -- Fetch the next database
    FETCH NEXT FROM db_cursor INTO @name
END

-- Clean up
CLOSE db_cursor
DEALLOCATE db_cursor

PRINT 'All database backups and verification completed.'