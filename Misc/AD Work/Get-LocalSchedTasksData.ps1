﻿invoke-command -ComputerName 'server' -ScriptBlock { 
  $sched = New-Object -Com 'Schedule.Service'
  $sched.Connect()
  
  $out = @()
  $sched.GetFolder('\').GetTasks(0) | ForEach-Object {
    $xml = [xml]$_.xml
    $out += New-Object psobject -Property @{
        'Name'          = $_.Name
        'Status'        = switch($_.State) {0 {'Unknown'} 1 {'Disabled'} 2 {'Queued'} 3 {'Ready'} 4 {'Running'}}
        'NextRunTime'   = $_.NextRunTime
        'LastRunTime'   = $_.LastRunTime
        'LastRunResult' = $_.LastTaskResult
        'Author'        = $xml.Task.Principals.Principal.UserId
        'Created'       = $xml.Task.RegistrationInfo.Date
    }
  }

  $out | Format-List Name,Status,NextRuNTime,LastRunTime,LastRunResult,Author,Created
}
