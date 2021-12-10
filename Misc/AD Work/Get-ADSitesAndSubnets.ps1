# two methods to extract this information

# OPTION 1
#pulls report of AD Sites and Subnets from Config section of domain
$results = Get-QADObject -ou '<domain>.root/Configuration/Sites' -ip siteObjectBL -SearchScope OneLevel -Type site | Sort-Object $_.Name |  ForEach-Object{
  $Name = $_.name
  $Type = 'Site'
  #$Subnets = [string]::join('; ', ( $_.siteObjectBL| %{ ($_ -split ',*..=')[1] }) )
  $Subnets = ( $_.siteObjectBL| ForEach-Object{ ($_ -split ',*..=')[1]} ) -join '; '

  #fetch the assigned DC to the site
  $ServerPath = '<domain>.root/Configuration/Sites/{0}/Servers' -f $Name
  $DCServer = (Get-QADObject -Proxy -ou $ServerPath -Type server | ForEach-Object{ $_.name }) -join '; '  

  [PSCustomObject] @{
    Name = $Name
    Type = $Type
    DC = $DCServer
    Subnets = $Subnets
  }
    
}

$results | Out-GridView

#
# OPTION 2
#
Get-ADReplicationSubnet -Filter * | Select-Object Name, Site

#expanded AD example #1
$edc = 'CN=EDC,CN=Sites,CN=Configuration,DC=<domain>,DC=root'
Get-ADReplicationSubnet -Filter {Site -eq $edc} | Select-Object Name, Site | Sort-Object Name | Out-GridView

#expanded AD example #2
$edc = 'CN=EDC,CN=Sites,CN=Configuration,DC=<domain>,DC=root'
Get-ADReplicationSubnet -Filter {Site -eq $edc} | 
  Select-Object Name, @{n='Site Name';e={Get-NamefromDN $_.site }} , Site | 
  Sort-Object Name | 
  Out-GridView -title 'ADSS - EDC Site Report'