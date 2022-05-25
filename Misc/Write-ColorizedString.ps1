Function Write-ColorizedString {
    [cmdletbinding()]
    Param (
        [String[]]
        $InputText,
        
        [string]
        $NumericColor,

        [string]
        $LiteralColor,

        [string]
        $SpecialColor
    )

    begin {
        $NumberChars  = 48..57
        $LiteralChars = 97..122
        $SpecialChars = 35..43
    }

    process {

        Foreach ($i in $InputText.ToCharArray()) { 

            switch ($i) {
                { [byte][char]$i -in $NumberChars }  { $OutputColor = $NumericColor }
                { [byte][char]$i -in $LiteralChars } { $OutputColor = $LiteralColor }
                { [byte][char]$i -in $SpecialChars } { $OutputColor = $SpecialColor }
                Default {}
            }

            Write-Host $i -Foreground $OutputColor -NoNewLine -BackgroundColor white
        }

    }
}

$MyRandomString = -join ((48..57) + (35..43) + (97..122) | Get-Random -Count 15 | ForEach-Object { [char]$_ })

Write-ColorizedString -InputText $MyRandomString -NumericColor Red -LiteralColor blue -SpecialColor green -Verbose

