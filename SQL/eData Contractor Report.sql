/****** Script for eData Contractors Records Report from Warehouse.  ******/
/****** Casts date fields into string format for CSV output.         ******/
/****** Default is to see how many contractors have flowed through   ******/
/****** IDM view since Jan 2017.								     ******/

SELECT  [EmployeeNumber]
      ,[SN]
      ,[FirstName]      
      ,[Office]
      ,[Location]      
      ,[Title]
	  ,[DisplayTitle]  
      ,[DepartmentCode]
      ,[DepartmentName]
	  
      ,CAST([HireDate] as varchar(30)) 
	  As HireDate
	  
      ,CAST([AdjustedHireDate] as varchar(30)) 
	  As AdjustedHireDate
	  
      ,CAST([TermDate] as varchar(30))
	  As TermDate 
	  
	  ,CAST([AccessRemoveDate] as varchar(30))
	  As AccessRemoveDate
	  
      ,[Status]
      ,[STAFF_CATEGORY_DESCRIPTION]
      ,[STAFF_CATEGORY]
      ,[nickname]      
      ,[DeptRollupDesc]
      ,[DeptRollupCode]          
      ,[email]
      ,[JobStatus]     
      ,[JobCode]
     
 FROM [ApplicationSemanticLayer].[ADS].[V_ADS_INFO]
 where DepartmentCode = 090310 and AdjustedHireDate > '2017-01-01' and JobCode	= 'C2080'