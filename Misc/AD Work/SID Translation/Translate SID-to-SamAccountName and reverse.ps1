# locate SID value of network account

$objUser = New-Object System.Security.Principal.NTAccount('<domain>', '<samAccountName>')
$strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
$strSID.Value

# OR find acount name by SID

$objSID = New-Object System.Security.Principal.SecurityIdentifier `
    ('S-1-5-21-1995508889-854850475-3617568098-6461')
( $objSID.Translate([System.Security.Principal.NTAccount]) ).value

