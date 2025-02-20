-- Set the desired compatibility level
DECLARE @desired_compatibility_level INT = 150; -- Change this to the desired compatibility level

-- Variable declarations
DECLARE @database_name NVARCHAR(128);
DECLARE @sql NVARCHAR(MAX);

-- Cursor to iterate through each database
DECLARE db_cursor CURSOR FOR
SELECT name
FROM sys.databases
WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb'); -- Exclude system databases

-- Open the cursor
OPEN db_cursor;

-- Fetch the first database
FETCH NEXT FROM db_cursor INTO @database_name;

-- Loop through each database
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Construct the SQL statement to change the compatibility level
    SET @sql = N'ALTER DATABASE ' + QUOTENAME(@database_name) + N' SET COMPATIBILITY_LEVEL = ' + CAST(@desired_compatibility_level AS NVARCHAR(3)) + N';';
    
    -- Print the SQL statement (optional for debugging)
    PRINT @sql;

    -- Execute the SQL statement
    EXEC sp_executesql @sql;

    -- Fetch the next database
    FETCH NEXT FROM db_cursor INTO @database_name;
END;

-- Close and deallocate the cursor
CLOSE db_cursor;
DEALLOCATE db_cursor;