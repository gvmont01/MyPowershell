$adspath = "LDAP://DC=<domain>,DC=net"
$root    = [System.DirectoryServices.DirectoryEntry]$adsPath

$search           = [System.DirectoryServices.DirectorySearcher]$root
$search.Filter    = "(&(isDeleted=TRUE)(objectclass=group))"
$search.tombstone = $true
$result           = $search.Findall()
$result |  where{ 	$_.properties.lastknownparent -like "*OU=Groups,DC=<domain>,DC=net*"} | foreach{$_.properties.samaccountname; Write-host ""	}

