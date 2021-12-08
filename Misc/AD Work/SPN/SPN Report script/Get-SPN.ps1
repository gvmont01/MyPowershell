function Get-Spn
{
  #EXAMPLE: Get-SPN MSSQLSvc
  param
  (
    [string]
    $ServiceType
  )

    $filter = "(servicePrincipalName=$serviceType/*)"
    $domain = New-Object System.DirectoryServices.DirectoryEntry
    $searcher = New-Object System.DirectoryServices.DirectorySearcher
    $searcher.SearchRoot = $domain
    $searcher.PageSize = 1000
    $searcher.Filter = $filter
    $results = $searcher.FindAll()

    foreach ($result in $results) {
        $account = $result.GetDirectoryEntry()
        foreach ($spn in $account.servicePrincipalName.Value) {
            if($spn -match "^MSSQLSvc\/(?<computer>[^\.|^:]+)[^:]*(:{1}(?<port>\w+))?$") {
                new-object psobject -property @{ComputerName=$matches.computer;Port=$matches.port;AccountName=$($account.Name);SPN=$spn} 

            } 
        }
    }

} 

Get-SPN | where {$_.AccountName -match '!QADSSQLSRV01'}