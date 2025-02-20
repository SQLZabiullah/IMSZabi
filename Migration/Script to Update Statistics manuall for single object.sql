--SQL Server UPDATE STATISTICS for all statistics in an object
Update STATISTICS HumanResources.Employee
--SQL Server UPDATE STATISTICS for specific statistics
Update STATISTICS HumanResources.Employee IX_Employee_OrganizationNode

--: SQL Server UPDATE STATISTICS with FULL Scan (scan all rows of a table)
Update STATISTICS HumanResources.Employee IX_Employee_OrganizationNode WITH FULLSCAN
Update STATISTICS HumanResources.Employee IX_Employee_OrganizationNode WITH SAMPLE 100 PERCENT
--UPDATE STATISTICS with SAMPLE (specify the percentage or number of rows for the query optimizer to update statistics.)
Update STATISTICS HumanResources.Employee IX_Employee_OrganizationNode WITH SAMPLE 10 PERCENT
Update STATISTICS HumanResources.Employee IX_Employee_OrganizationNode WITH SAMPLE 1000 ROWS

--update all statistics in the database
exec sp_updatestats