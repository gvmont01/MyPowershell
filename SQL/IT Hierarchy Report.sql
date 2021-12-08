--Load initial IT Director CTE query
--Change the empID value to the director for the correct report
WITH Managers AS 
( 
--initialization 
SELECT  EmployeeNumber
  , FullName
  , Title
  , OfficeCity
  , DepartmentName
  , Manager1_Employee
   , [Manager1first_name]+' '+[Manager1last_name] AS ManagerName
FROM [ApplicationSemanticLayer].[ADS].[V_ADS_INFO] 
where Manager1_Employee = 73643 and TermDate is null 
--UNION
UNION ALL 
--recursive execution 
SELECT e.EmployeeNumber, e.FullName, e.Title, e.OfficeCity, e.DepartmentName, e.Manager1_Employee, e.[Manager1first_name]+' '+e.[Manager1last_name] AS ManagerName 
FROM [ApplicationSemanticLayer].[ADS].[V_ADS_INFO] e INNER JOIN Managers m  
ON e.Manager1_Employee = m.EmployeeNumber 
where e.TermDate is null
) 
--Now grab all records from union
SELECT * FROM Managers 

  -- Naphy 73676
  -- Street 72243
  -- Phillips 54390
  -- Mangipet 92393
  -- Moliere 73643


  