DECLARE @backupDirectory NVARCHAR(255) = 'C:\Backup\' -- Path to your backup directory
DECLARE @command NVARCHAR(MAX)
DECLARE @databaseName NVARCHAR(255)
DECLARE @backupFile NVARCHAR(255)
DECLARE @restoreFileList TABLE (
    LogicalName NVARCHAR(128),
    PhysicalName NVARCHAR(260),
    Type CHAR(1),
    FileGroupName NVARCHAR(128),
    Size BIGINT,
    MaxSize BIGINT,
    FileId INT,
    CreateLSN NUMERIC(25,0),
    DropLSN NUMERIC(25,0),
    UniqueId UNIQUEIDENTIFIER,
    ReadOnlyLSN NUMERIC(25,0),
    ReadWriteLSN NUMERIC(25,0),
    BackupSizeInBytes BIGINT,
    SourceBlockSize INT,
    FileGroupId INT,
    LogGroupGUID UNIQUEIDENTIFIER,
    DifferentialBaseLSN NUMERIC(25,0),
    DifferentialBaseGUID UNIQUEIDENTIFIER,
    IsReadOnly BIT,
    IsPresent BIT,
    TDEThumbprint VARBINARY(32)
)

-- Get a list of backup files in the directory
DECLARE backupFiles CURSOR FOR
SELECT name
FROM xp_dirtree @backupDirectory, 1
WHERE RIGHT(name, 4) = '.bak'

OPEN backupFiles
FETCH NEXT FROM backupFiles INTO @backupFile

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @databaseName = REPLACE(@backupFile, '.bak', '')

    -- Get the logical names of the files in the backup
    SET @command = 'RESTORE FILELISTONLY FROM DISK = ''' + @backupDirectory + @backupFile + ''''
    TRUNCATE TABLE @restoreFileList
    INSERT INTO @restoreFileList
    EXEC(@command)

    -- Construct the RESTORE DATABASE command
    SET @command = 'RESTORE DATABASE [' + @databaseName + '] FROM DISK = ''' + @backupDirectory + @backupFile + ''' WITH REPLACE, '

    -- Add the MOVE options for each file
    SELECT @command = @command + 'MOVE ''' + LogicalName + ''' TO ''' + PhysicalName + ''', '
    FROM @restoreFileList

    -- Remove the trailing comma and space
    SET @command = LEFT(@command, LEN(@command) - 2)

    -- Execute the RESTORE DATABASE command
    PRINT @command
    EXEC(@command)

    FETCH NEXT FROM backupFiles INTO @backupFile
END

CLOSE backupFiles
DEALLOCATE backupFiles