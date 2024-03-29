Function Get-FSMORoleHolders {            
  param
  (
    [string]$DomainName = '<domain>.net',
    [string]$ForestName = '<domain>.root'
  )
  
  if (-not (get-module activedirectory)) {
    Import-Module activedirectory 
  }          

  $Domain = Get-ADDomain $DomainName
  $Forest = Get-ADForest $ForestName            

  [PSCustomObject][Ordered] @{
    PDC            = $domain.PDCEmulator
    RID            = $Domain.RIDMaster
    Infrastructure = $Domain.InfrastructureMaster
    Schema         = $Forest.SchemaMaster
    DomainNaming   = $Forest.DomainNamingMaster
  }
}

#USAGE EXAMPLES

#for foreign domains
#Get-FSMORoleHolders -DomainName <domain>.com -ForestName <domain>.com

#for default domain leave blank
Get-FSMORoleHolders | Out-GridView