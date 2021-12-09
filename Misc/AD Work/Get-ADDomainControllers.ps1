$results = (Get-ADForest).Domains | %{ Get-ADDomainController -Filter * -Server $_ | select HostName, IPv4Address, site, IsGlobalCatalog }

$results | ogv -Title '<domain> domain - All Domain Controllers'