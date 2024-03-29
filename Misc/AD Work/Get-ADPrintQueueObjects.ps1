# Get-ADPrintQueueObjects.ps1
# 6/3/2014 - modified for lookup for MFDs only
Get-QADObject -SearchRoot 'dc=<domain>,dc=net' -sl 0 -Type printQueue | Where-Object{$_.name -match 'MFD'} | Select-Object name | sort name
