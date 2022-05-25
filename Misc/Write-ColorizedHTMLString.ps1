Function Write-ColorizedHTMLString {
    [cmdletbinding()]
    Param (
        [String]
        $InputText,
        
        [string]
        $NumericColor,

        [string]
        $LiteralColor,

        [string]
        $SpecialColor,

        [System.IO.FileInfo]
        [ValidateScript({
                if ($_ -notmatch '(\.htm|\.html)') {
                    throw 'The file specified in the path argument must be either of type htm or html.'
                }
                return $true
            })]
        $outFile
    )

    begin {
        $NumberChars  = 48..57
        $LiteralChars = 97..122
        $SpecialChars = 35..43

        Write-Verbose "Inputtext var length is $($InputText.Length)"

        $HTMLHeader = @"
        <html xmlns=http://www.w3.org/1999/xhtml>
        <head>
        <title>Colorized String Function</title>
        <style>
        body {
            background-color: Gainsboro;
            font-family: Monospace;
            font-size: 10pt;
            }
            table, th, td{
                border: 0px solid;
                margin-right: auto;
                margin-left: auto;
                text-align: center; 
                vertical-align: middle;
            }
            h1{
                color:#6D7B8D;
                text-align: center;
            }
            h5{
                color:black;
                text-align: left;
            }
            .Numeric {
                color: $NumericColor;
                font-family: Tahoma;
                font-size: 10pt;
                font-weight: bold;
            }
            .Literal {
                color: $LiteralColor;
                font-family: Tahoma;
                font-size: 10pt;
                font-weight: normal;
            }
            .Special {
                color: $SpecialColor;
                font-family: Tahoma;
                font-size: 10pt;
                font-weight: normal;
            }
        </style>
        </head>
        <body>
        <H1>Write-ColorizedHTMLString</H1>
        <table>
        <tr><th><H3>Your original string:</H3></th></tr>
        <tr><td>$InputText</td></tr>
        <tr height="30px"><td></td></tr>
        <tr><th rowspan=$($InputText.Length)><H3>Your colorized string:</H3></th></tr>
        <tr>
"@
        $HTMLFooter = @"
            </tr>    
        </table>
        <H5><i>$(Get-Date)</i></H5>
        </body>
        </html>
"@
    }

    process {

        $HTLMBody = Foreach ($i in $InputText.ToCharArray()) { 

            switch ($i) {
                { [byte][char]$i -in $NumberChars } { $OutputColor  = 'Numeric' }
                { [byte][char]$i -in $LiteralChars } { $OutputColor = 'Literal'}
                { [byte][char]$i -in $SpecialChars } { $OutputColor = 'Special' }
                Default {}
            }

            Write-Verbose "The char: $i"
            #HTML ouput per character
            "<td class=$outputcolor>$i</td>"
        }

        #output to HTML
        <# $HTLMBody -join '' | ConvertTo-Html -Title 'Colorized String Function' -PreContent '<H1>Write-ColorizedHTMLString</H1>' `
            -PostContent "<H5><i>$(Get-Date)</i></H5>" -Head $HTMLStyleSheet | Out-File $outFile #>
    }

    end {
        $HTMLHeader + $HTLMBody + $HTMLFooter | Out-File $outFile
    }
}
$FilePath = 'C:\temp\Reports\WriteString.htm'
$MyRandomString = -join ((48..57) + (35..43) + (97..122) | Get-Random -Count 15 | ForEach-Object { [char]$_ })

Write-ColorizedHTMLString -InputText $MyRandomString -NumericColor Red -LiteralColor blue -SpecialColor green -outFile $FilePath -Verbose
ii $FilePath