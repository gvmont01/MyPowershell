# Get-ADPrintQueueObjects.ps1
# 6/3/2014 - modified for lookup for MFDs only
Get-QADObject -SearchRoot 'dc=<domain>,dc=net' -sl 0 -Type printQueue | ?{$_.name -match 'MFD'} | select name | sort name
