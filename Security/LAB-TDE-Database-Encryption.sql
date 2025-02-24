USE master;
GO

---create master key

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'pass#12';
go
---create CERTIFICATE

Create CERTIFICATE DNTServerCert WITH SUBJECT = 'DNT DEK Certificate'
go


--  Also create a backup of the certificate with the private key and store it in a secure location. (
/* Note that the private key is stored in a separate file—be sure to keep both files). 
Be sure to maintain backups of the certificate as data loss may occur otherwise. */

BACKUP CERTIFICATE DNTServerCert TO FILE = 'E:\DNT_Springfiled\Security\Security_2\DNTServerCert'

   WITH PRIVATE KEY (

         FILE = 'E:\DNT_Springfiled\Security\Security_2\private_key_file',

         ENCRYPTION BY PASSWORD = 'pass#12');
 --Perform the following steps in the user database. These require CONTROL permissions on the database.

--4.    Create the database encryption key (DEK) encrypted with the certificate designated from step 2 above. This certificate 
--      is referenced as a server certificate to distinguish it from other certificates that may be stored in the user database.        
USE   DNT_Sample_TDE
GO

CREATE DATABASE ENCRYPTION KEY
WITH  ALGORITHM = AES_128
ENCRYPTION BY SERVER CERTIFICATE DNTServerCert
GO

 --Enable TDE. This command starts a background thread (referred to as the encryption scan), which runs asynchronously.
ALTER DATABASE DNT_Sample_TDE
SET ENCRYPTION on
GO

--To monitor progress, query the sys.dm_database_encryption_keys view (the VIEW SERVER STATE permission is required) as in the following example
select DB_NAME(database_id), encryption_state
from sys.dm_database_encryption_keys
