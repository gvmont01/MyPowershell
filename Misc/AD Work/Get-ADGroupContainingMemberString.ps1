#AD_CSGGroupsContainingPSAccts.ps1

$Now            = Get-Date
$LogFileDate    = '{0:MMddyyyyhhmmss}' -f $Now
[int]$cnt = 0

# Define the search string
$searchString = 'passwordsafe'

#group query call here
$DNPath = '<DNpath here>'
$CSG_GrpQuery = Get-ADGroup -SearchBase $DNPath -Filter { Name -like 'CSG_*' } -Properties name, member | Select-Object Name, member

Write-Host 'Group query completed' -ForegroundColor Green

#process the results to look specifically for PS accts in membership
$results = $CSG_GrpQuery | ForEach-Object {
    $GrpName = $_.name

    #Progress
    $cnt++
    Write-Progress -activity "Processing Group Search" -status "Status: Parsing $GrpName" -percentComplete (($cnt / $CSG_GrpQuery.count)*100)

    If (($_.member) -match $searchString) {

        Write-Host 'Search string located - writing to object' -ForegroundColor Blue

        [PSCustomObject] @{
            name   = $GrpName
            Member = [string]::join('; ', ($_.member | ForEach-Object {
                
                        If (($_) -match $searchString) {
                            ($_.replace('\', '') -split ',*..=')[1] | Sort-Object
                        }

                    } ) )  
        }
    }      
}

$results | Export-Csv C:\temp\Reports\CSG_Groups_PSMembersOnly_$LogFileDate.csv -NoTypeInformation