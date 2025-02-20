
    DECLARE @db sysname, @q varchar(max);
    DECLARE cur_db CURSOR FOR
        SELECT name FROM sys.databases WHERE owner_sid<>0x01;
    OPEN cur_db;
    WHILE 1=1
    BEGIN
        FETCH NEXT FROM cur_db INTO @db;
        IF @@FETCH_STATUS <> 0
            BREAK;
        SET @q = N'ALTER DATABASE [' + @db + N'] SET OFFLINE WITH NO_WAIT';
        EXEC(@q);
    END;
    CLOSE cur_db;
    DEALLOCATE cur_db;
