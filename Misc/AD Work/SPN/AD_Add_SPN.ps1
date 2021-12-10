#Script handles SPN creations
#Example of a request below:
#1. Create the following SPN for service account <domain>\!CODSSQLSRV01
#
#MSSQLSvc/COVSQLD11.<domain>.net:1433 
#
#2. Enable Kerberos delegation on server COVSQLD11
#
#3. Create the following SPN for service account <domain>\!CODSSQASRV01
#
#MSOLAPSvc.3/COVSQLA02.<domain>.net
#MSOLAPSvc.3/COVSQLA02.<domain>.net:TABULAR
#
#4.  Enable Kerberos delegation on server COVSQLA02
#
#5: Create SPN for the Browser Service on the Analysis Server COVSQLA02
#
#MSOLAPDisco.3/COVSQLA02.<domain>.net
#MSOLAPDisco.3/COVSQLA02

#load AD module if necessary
function LoadADModule {
  # Load AD Module (if not already)
  if ($null -eq (Get-Module ActiveDirectory -ErrorAction SilentlyContinue)){
    Import-Module ActiveDirectory
  }
}
 #region OPTION 1
LoadADModule

#$SPN = "MSSQLSvc/COVSQLD07.<domain>.net:1433","MSSQLSvc/CPVSQLD07.<domain>.net:1433" #array of values
$SPN = 'MSSQLSvc/COVSQLD24.<domain>.net:1433'
$ServiceAccount = '!CODSSQLSRV01' 

Set-ADUser -Identity $ServiceAccount -ServicePrincipalNames @{Add=$SPN} -TrustedForDelegation $true
#endregion

#region OPTION 2
$ServiceAccount = '<domain>\!STDSCLSQLSRV'
$NewSPNs = 'MSSQLSvc/STVSQLD51.<domain>.LOC:1433','MSSQLSvc/STVSQLD52.<domain>.LOC:1433'
Set-QADUser -Service <domain>.loc -Identity $ServiceAccount -objectAttributes @{servicePrincipalName=@{Append=@($NewSPNs)}}
#endregion

exit

#sample to search for the addition
$Account = $ServiceAccount.Split('\')[1]
Get-QADObject -SearchRoot 'dc=<domain>,dc=net' -ldapFilter "(servicePrincipalname=MSOLAPSvc.3*)" -IncludedProperties servicePrincipalName -sizeLimit 0 | Where-Object{$_.name -eq $Account} |
      select name,@{name='SPN';Expression={$_.servicePrincipalName -join "`n"} } | Out-GridView
			
#produces the report below
#****************
#Name : !STDSSQLSRV01
#SPN  : MSSQLSvc/STVSQLD04.<domain>.net:1433
#       MSSQLSvc/STVSQLD08.<domain>.net:1433
#       MSSQLSvc/STVSQLD02.<domain>.net
#       MSSQLSvc/STVSQLD07.<domain>.net
#       MSSQLSvc/STPSQLD01.<domain>.net:NS2
#       MSSQLSvc/STPSQLD01.<domain>.net:NS1