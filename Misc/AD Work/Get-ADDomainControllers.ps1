$results = (Get-ADForest).Domains | ForEach-Object{ Get-ADDomainController -Filter * -Server $_ | Select-Object HostName, IPv4Address, site, IsGlobalCatalog }

$results | Out-GridView -Title '<domain> domain - All Domain Controllers'