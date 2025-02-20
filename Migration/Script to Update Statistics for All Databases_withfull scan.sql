DECLARE @DatabaseName NVARCHAR(128);
DECLARE @SQL NVARCHAR(MAX);

-- Cursor to iterate through each database
DECLARE db_cursor CURSOR FOR
SELECT name
FROM sys.databases
WHERE state_desc = 'ONLINE' AND name NOT IN ('master', 'tempdb', 'model', 'msdb'); -- Exclude system databases

-- Open the cursor
OPEN db_cursor;

-- Fetch the first database
FETCH NEXT FROM db_cursor INTO @DatabaseName;

-- Loop through each database
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Construct the SQL statement to update statistics
    SET @SQL = 'USE [' + @DatabaseName + '];' + CHAR(13) +
               'EXEC sp_MSforeachtable ''UPDATE STATISTICS ? WITH FULLSCAN'';';
    
    -- Print the SQL statement (optional for debugging)
    PRINT @SQL;

    -- Execute the SQL statement
    EXEC sp_executesql @SQL;

    -- Fetch the next database
    FETCH NEXT FROM db_cursor INTO @DatabaseName;
END;

-- Close and deallocate the cursor
CLOSE db_cursor;
DEALLOCATE db_cursor;