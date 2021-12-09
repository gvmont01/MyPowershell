<#
Remove SPN MSSQLSvc/STVSQLD01.<domain>.net:1433 from <domain>\!STDSSQLSRV01
 
Create SPN for service account <domain>\!STSQLSRV01
MSSQLSvc/STVSQLD01.<domain>.net:1433
#>
 
 
$acct = '!STDSSQLSRV01'
$DelSPN = 'MSSQLSvc/STVSQLD01.<domain>.net:1433'
Set-QADUser -Identity $acct -objectAttributes @{servicePrincipalName=@{Delete=$DelSPN}}