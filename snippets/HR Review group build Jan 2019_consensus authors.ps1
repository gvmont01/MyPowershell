#************************************************************
# Bulk group membership template 2018.ps1
# Created by Greg Montoya 2018
#
# Steps:
# 1) copy CSV to prod ARS box; write path to script
# 2) Create group and copy it's ID to script
# 3) update the EMPID field to match CSV file
# 4) after script completes check $results object for bad objects
#************************************************************

$collection = Import-Csv 'c:\temp\Consensus Author Distribution List 1.22.2018.csv'

$DLGroup = '2019 Staff and Secretary Evaluation Process Consensus Authors' # '2019 Staff and Secretary Evaluation Process Participants'

#library script for functions
. E:\Scripts\Functions\ARSTaskFunctions.ps1

[int]$cnt = 0 

$results = Foreach ($user in $collection){

  $cnt++
  $empID = $user.'Reviewer Internal ID'
  Write-Progress -activity 'Writing to Group' -status "Search -- $empID" -percentComplete (($cnt / $collection.count)*100)
  
  $LookUp = GetEx-UserAttribByEmpID -EmpID $empID -Properties ('dn','homeMDB') -IsActiveStatus $true -IsProxy $false
   
  #verify the account is active and is assigned a mailbox 
  if ( ([bool]$LookUp.dn) -and ([bool]$LookUp.homeMDB)){
    Add-QADGroupMember -Identity $DLGroup -Member $LookUp.dn  > $null
    Write-Host "Adding $empID"    
  }   
  
  [PSCustomObject] @{
       EMPID = $empID
       DN = $( if (-not [bool]$LookUp.dn){'Departed'}else{$LookUp.dn} )
       Mailbox = $( if (-not [bool]$LookUp.homeMDB){'No mailbox'}else{$LookUp.homeMDB} )
  }
  
}