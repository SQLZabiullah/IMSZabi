DECLARE @sql NVARCHAR(MAX) = N'', @stats NVARCHAR(MAX) = N'';

SELECT @sql += N'EXEC ' + QUOTENAME(name) + '.sys.sp_executesql @stats;'
  FROM sys.databases 
  WHERE [state] = 0 AND user_access = 0; -- and your other filters

SET @stats = N'DECLARE @inner NVARCHAR(MAX) = N''''; 
  SELECT @inner += CHAR(10) + N''UPDATE STATISTICS '' 
    + QUOTENAME(s.name) + ''.'' + QUOTENAME(t.name) + '';'' 
    FROM sys.tables AS t
    INNER JOIN sys.schemas AS s 
    ON t.[schema_id] = s.[schema_id];
  PRINT CHAR(10) + DB_NAME() + CHAR(10) + @inner;
  --EXEC sys.sp_executesql @inner;'

EXEC [master].sys.sp_executesql @sql, N'@stats NVARCHAR(MAX)', @stats;