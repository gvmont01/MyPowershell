--Load initial IT Director CTE query
--Change the empID value to the director for the correct report
WITH Managers AS 
( 
--initialization 
SELECT  EagleID
  , FullName
  , Title
  , OfficeCity
  , DepartmentName
  , Manager1_EmployeeEagleID
  , [Manager1first_name]+' '+[Manager1last_name] AS ManagerName
FROM AllPersons
where Manager1_Employee = 'EagleID' and TermDate is null 
--UNION
UNION ALL 
--recursive execution 
SELECT e.EagleID, e.FullName, e.Title, e.OfficeCity, e.DepartmentName, e.Manager1_EmployeeEagleID, 
       e.[Manager1first_name]+' '+e.[Manager1last_name] AS ManagerName 
FROM AllPersons e INNER JOIN Managers m  
ON e.Manager1_EmployeeEagleID = m.EagleID 
where e.TermDate is null
) 
--Now grab all records from union
SELECT * FROM Managers 
  