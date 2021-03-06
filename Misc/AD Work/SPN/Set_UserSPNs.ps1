 
$acct = '!STSQLSRV01'
$NewSPNs = 'MSSQLSvc/STVSQLD01.<domain>.net:1433' # 'MSSQLSvc/DVVSQLD01.<domain>.net:1433','MSSQLSvc/DVVSQLD02.<domain>.net:1433', 
#'MSSQLSvc/DVVSQLQ01.<domain>.net:1433', 'MSSQLSvc/DVVSQLQ02.<domain>.net:1433'


#use when contacting <domain> domain
#$acct = '<domain>\!STDSCLSQLSRV'
#Set-QADUser -Service <domain>.loc -Identity $acct -objectAttributes @{servicePrincipalName=@{Append=@($NewSPNs)}}

Set-QADUser -Identity $acct -objectAttributes @{servicePrincipalName=@{Append=@($NewSPNs)}}


#sample to search for the addition and send report to requestor
Get-QADObject -SearchRoot 'dc=<domain>,dc=net' -ldapFilter '(servicePrincipalname=MSSQLSvc*)' -IncludedProperties servicePrincipalName -sizeLimit 0 | Where-Object name -eq $acct |
      Select-Object name,@{name='SPN';Expression={$_.servicePrincipalName -join "`n"} } | Out-GridView