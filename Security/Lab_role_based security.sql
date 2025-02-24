CREATE ROLE Admin;
CREATE ROLE Manager;
CREATE ROLE [User];
CREATE ROLE writer;


GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.Employees TO Admin;
GRANT SELECT, INSERT, UPDATE ON dbo.Employees TO Manager;
GRANT SELECT ON dbo.Employees TO [User];
GRANT  INSERT, UPDATE ON dbo.Employees TO writer;

ALTER ROLE Admin ADD MEMBER [username1];
ALTER ROLE Manager ADD MEMBER [username2];
ALTER ROLE [User] ADD MEMBER [username3];
ALTER ROLE [writer] ADD MEMBER [username4];

CREATE FUNCTION dbo.EmployeeSecurityPredicate
(@CustomerID int)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN SELECT 1 AS Result
FROM dbo.Employees AS e
WHERE e.CustomerID = @CustomerID OR IS_MEMBER('Admin') = 1;

CREATE SECURITY POLICY EmployeeSecurityPolicy
ADD FILTER PREDICATE dbo.EmployeeSecurityPredicate(CustomerID)
ON dbo.Employees
WITH (STATE = ON);


GRANT EXECUTE ON dbo.usp_UpdateEmployee TO Admin;
GRANT EXECUTE ON dbo.usp_GetEmployeeDetails TO Manager, [User];

CREATE SCHEMA HR;
ALTER AUTHORIZATION ON SCHEMA::HR TO Admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::HR TO Manager;
GRANT SELECT ON SCHEMA::HR TO [User];



SELECT r.name AS RoleName,
       m.name AS MemberName
FROM sys.database_role_members drm
JOIN sys.database_principals r ON drm.role_principal_id = r.principal_id
JOIN sys.database_principals m ON drm.member_principal_id = m.principal_id;




