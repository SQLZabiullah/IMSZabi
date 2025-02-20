
sp_recompile 'procedureName'

sp_recompile 'uspGetWhereUsedProductID'

--all procudre or function 
DECLARE C CURSOR FOR (SELECT [name] FROM sys.objects WHERE [type] IN ('P', 'FN', 'IF'));
DECLARE @name SYSNAME;
OPEN C;
FETCH NEXT FROM C INTO @name;
WHILE @@FETCH_STATUS=0 BEGIN
    EXEC sp_recompile @name;
    FETCH NEXT FROM C INTO @name;
END;

--or 
DECLARE @sql NVARCHAR(MAX) = '';
SELECT @sql += 'EXEC sp_recompile '''+[name]+''''+CHAR(10) FROM sys.objects WHERE [type] IN ('P', 'FN', 'IF');
EXEC (@sql);
CLOSE C;
DEALLOCATE C