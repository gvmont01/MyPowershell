Function New-TimeSpanExtract {
    param(
        [datetime]$Start,
        [datetime]$End
    )

    begin{
    $workDays = 0
    $span     = New-TimeSpan -Start $Start -End $End
    }

    process{
        
        $TheDays    = $span.TotalDays
        $TheHours   = $span.TotalHours
        $TheMinutes = $span.TotalMinutes
        $TheYears   = (New-Object DateTime -ArgumentList $span.ticks).Year -1

        #get workdays  - this is the fastest loop construct!
        for ($d=$start;$d -le $end;$d=$d.AddDays(1)){
            if ($d.DayOfWeek -notmatch "Sunday|Saturday") {
                $workDays++
            }
        }

       #proper span format 
       $TotalSpan = '{0} years, {1} days, {2} hours, {3} minutes, {4} seconds' -f $TheYears, $(($span.days) % 365), $span.hours, $span.Minutes, $span.Seconds 
              
       [PSCustomObject] @{
            'Total Minutes'  = $TheMinutes
            'Total Hours'    = $TheHours
            'Total Days'     = $TheDays
            'Total Workdays' = $workDays
            'Total Weeks'    = $TheDays/7
            'Total Years'    = $TheYears
            'Total Span'     = $TotalSpan
       }
       
    }

}

$Start = Get-Date '12/13/2021'
$End   = Get-Date

New-TimeSpanExtract -Start $Start -End $End