DECLARE @dbName NVARCHAR(255)
DECLARE @command NVARCHAR(MAX)

-- Create a table to log results
IF OBJECT_ID('tempdb..#DBCCResults') IS NOT NULL
    DROP TABLE #DBCCResults

CREATE TABLE #DBCCResults (
    DatabaseName NVARCHAR(255),
    Message NVARCHAR(MAX)
)

-- Cursor to iterate through all databases
DECLARE db_cursor CURSOR FOR
SELECT name
FROM sys.databases
WHERE state_desc = 'ONLINE'  -- Only check online databases

OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @dbName

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @command = 'DBCC CHECKDB ([' + @dbName + ']) WITH NO_INFOMSGS, ALL_ERRORMSGS'

    -- Insert the results into the logging table
    INSERT INTO #DBCCResults (DatabaseName, Message)
    EXEC sp_executesql @command

    FETCH NEXT FROM db_cursor INTO @dbName
END

CLOSE db_cursor
DEALLOCATE db_cursor

-- Display the results
SELECT * FROM #DBCCResults
Explanation: