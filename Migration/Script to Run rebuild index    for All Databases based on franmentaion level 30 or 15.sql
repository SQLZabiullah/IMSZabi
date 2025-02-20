DECLARE @DatabaseName NVARCHAR(128);
DECLARE @TableName NVARCHAR(128);
DECLARE @IndexName NVARCHAR(128);
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
    SET @SQL = 'USE [' + @DatabaseName + '];' + CHAR(13) +
               'DECLARE @TableName NVARCHAR(128);' + CHAR(13) +
               'DECLARE @IndexName NVARCHAR(128);' + CHAR(13) +
               'DECLARE @SQL NVARCHAR(MAX);' + CHAR(13) +
               'DECLARE index_cursor CURSOR FOR' + CHAR(13) +
               'SELECT t.name AS TableName, i.name AS IndexName' + CHAR(13) +
               'FROM sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, ''LIMITED'') AS ips' + CHAR(13) +
               'JOIN sys.indexes AS i ON ips.object_id = i.object_id AND ips.index_id = i.index_id' + CHAR(13) +
               'JOIN sys.tables AS t ON i.object_id = t.object_id' + CHAR(13) +
               'WHERE ips.avg_fragmentation_in_percent > 5 AND t.is_ms_shipped = 0;' + CHAR(13) +
               'OPEN index_cursor;' + CHAR(13) +
               'FETCH NEXT FROM index_cursor INTO @TableName, @IndexName;' + CHAR(13) +
               'WHILE @@FETCH_STATUS = 0' + CHAR(13) +
               'BEGIN' + CHAR(13) +
               '   IF EXISTS (SELECT 1 FROM sys.dm_db_index_physical_stats (DB_ID(), OBJECT_ID(@TableName), INDEXPROPERTY(OBJECT_ID(@TableName), @IndexName, ''IndexID''), NULL, ''LIMITED'') WHERE avg_fragmentation_in_percent >= 30)' + CHAR(13) +
               '   BEGIN' + CHAR(13) +
               '       SET @SQL = ''ALTER INDEX ['' + @IndexName + ''] ON ['' + @TableName + ''] REBUILD;'';' + CHAR(13) +
               '       EXEC sp_executesql @SQL;' + CHAR(13) +
               '       PRINT ''Rebuilt index '' + @IndexName + '' on table '' + @TableName;' + CHAR(13) +
               '   END' + CHAR(13) +
               '   ELSE IF EXISTS (SELECT 1 FROM sys.dm_db_index_physical_stats (DB_ID(), OBJECT_ID(@TableName), INDEXPROPERTY(OBJECT_ID(@TableName), @IndexName, ''IndexID''), NULL, ''LIMITED'') WHERE avg_fragmentation_in_percent BETWEEN 5 AND 30)' + CHAR(13) +
               '   BEGIN' + CHAR(13) +
               '       SET @SQL = ''ALTER INDEX ['' + @IndexName + ''] ON ['' + @TableName + ''] REORGANIZE;'';' + CHAR(13) +
               '       EXEC sp_executesql @SQL;' + CHAR(13) +
               '       PRINT ''Reorganized index '' + @IndexName + '' on table '' + @TableName;' + CHAR(13) +
               '   END' + CHAR(13) +
               '   FETCH NEXT FROM index_cursor INTO @TableName, @IndexName;' + CHAR(13) +
               'END;' + CHAR(13) +
               'CLOSE index_cursor;' + CHAR(13) +
               'DEALLOCATE index_cursor;';
    
    -- Execute the SQL statement
    EXEC sp_executesql @SQL;

    -- Fetch the next database
    FETCH NEXT FROM db_cursor INTO @DatabaseName;
END;

-- Close and deallocate the cursor
CLOSE db_cursor;
DEALLOCATE db_cursor;
