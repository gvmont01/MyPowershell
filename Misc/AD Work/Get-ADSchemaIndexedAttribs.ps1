#Get-ADSchemaIndexedAttribs.ps1
#Created by Greg Montoya 12-14-2012

begin{
  ##requires the AD module to locate the Schema path
  if(!(Get-Module ActiveDirectory)) {
    Write-Host 'Importing AD Module..' -fore Blue
    Import-Module ActiveDirectory 
  }  
  
  $now = Get-Date
  $ReportFileDate = '{0:MMddyyyyhhmmss}' -f $Now 
}

process{
  #pull the Schema path - for Morgan it's 'CN=Schema,CN=Configuration,DC=Firm,DC=root' 
  $SchemaPartition = (Get-ADRootDSE).NamingContexts | Where-Object {$_ -like "*Schema*"} 
 
  Get-QADObject -SearchRoot $SchemaPartition `
                -Type attributeSchema -IncludedProperties systemFlags `
                -SizeLimit 0 -LdapFilter '(searchFlags:1.2.840.113556.1.4.803:=1)' `
                -SearchScope OneLevel | 
    Select-Object name | Sort-Object | Export-Csv c:\temp\reports\Indexed_Attribs_$ReportFileDate.csv -NoTypeInformation
}