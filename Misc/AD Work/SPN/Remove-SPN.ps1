<#
Remove SPN MSSQLSvc/STVSQLD01.Morganlewis.net:1433 from Morganlewis\!STDSSQLSRV01
 
Create SPN for service account Morganlewis\!STSQLSRV01
MSSQLSvc/STVSQLD01.Morganlewis.net:1433
#>
 
 
$acct = '!STDSSQLSRV01'
$DelSPN = 'MSSQLSvc/STVSQLD01.Morganlewis.net:1433'
Set-QADUser -Identity $acct -objectAttributes @{servicePrincipalName=@{Delete=$DelSPN}}