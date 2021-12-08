#region NOTES
# ARS_PS_SetUserADPhotos.ps1
# Created by Greg Montoya 5/13/2014
#
# Notes: 1) Reads image files from CIFS share and uploads them to AD
#	   		 2) User must be present in OFFICES OU for the update
#	    		 3) Image size is 30k or less with dimensions no more than 200x200
# Changes:
# more here -- http://blog.lyon-marrian.com/2013/10/auto-update-ad-pictures-powershell-script/
#endregion ************************************************************
function Set-ADUserPhotos
{
  <#
    .SYNOPSIS
    Short Description
    .DESCRIPTION
    Detailed Description
    .EXAMPLE
    Set-ADUserPhotos
    explains how to use the command
    can be multiple lines
    .EXAMPLE
    Set-ADUserPhotos
    another example
    can have as many examples as you like
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$true, Position=0)]
    [System.String]
    $ImagePath,
    
    [Parameter(Mandatory=$false, Position=1)]
    [ValidateScript({Test-Path $_})] 
    [String] 
    $ReportFolder
  )
  
  begin
  {    
    $Now = Get-Date 
    $FileDateToCompare = ($Now).AddDays(-1)
    $LogFileDate = '{0:MMddyyyyhhmmss}' -f $Now
    $LogPath = "$ReportFolder\ADPhotoSync--$LogFileDate.log"
    $AllErrors = @() #place holder for tracking all errant objects
  
    #region Functions
    function Send-ITAlert {
      param ($AllErrors)
      #uses the initial array to see if there are errors to report
      If ($AllErrors){
        $EmailSubject = 'Alert - AD Photo bulk update errors report'
        $MailTo = 'zzIDMTeam (Local) <zzidmteam@morganlewis.com>' 
        $MailFrom = 'Quest ARS Admin <QARSAdmin@morganlewis.com>'
        $AlertMsg = $AllErrors | Select-Object * | ConvertTo-Html
        Send-MailMessage -To $MailTo -From  $MailFrom -Subject $EmailSubject -Body $AlertMsg -Priority High -BodyAsHtml  -SmtpServer CORelay	
      }
    }
    function Set-ADPicture {
      param ($EmployeeID, $UserPhoto)
      #user must be in active status (in OFFICES OU) to have their photo updated; set Searchroot param accordingly
      $User = Get-QADUser -SearchRoot 'OU=offices,DC=morganlewis,DC=net' -sl 0  -oa @{employeeID=$EmployeeID} `
      -DontUseDefaultIncludedProperties -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
      
      If ([bool]$User){
        $UserLogon = 'morganlewis\{0}' -f $User.samAccountName
        Write-Verbose "User located in AD - $UserLogon; updating object property"
        Set-QADUser -Identity $UserLogon -ObjectAttributes @{thumbnailPhoto=$UserPhoto} > $null
        $User = $Null
      } else {
        Write-Verbose "$EmployeeID not located in AD"
        #send alert to IDM Team? If so, send hashtable of all accts, or one-by-one?
        $Subject = "User empID $EmployeeID not found in AD"
        $Body = ' '
        #Send-ITAlert $Subject $Body 
      }
    }
    function New-ErrorHistory {
      param ($FileName, $ErrMsg)		
      #output   
      $AllErrors += [PSCustomObject][Ordered] @{
        'File' = $FileName
        'ErrorMsg' = $ErrMsg 
      } 
    }
    #endregion
  }
 
  process
  {
    #fLog $LogPath "Begin processing..."
    Get-ChildItem $ImagePath\*.jpg | ForEach-Object {
      $ImageFileName = $_.name
      Write-Verbose "Processing $ImageFileName"
      #fLog $LogPath "processing $ImageFileName"
      [string]$BaseName = $_.BaseName
    
      #filter only for those files that have at least 5 chars for name and are numeric in value
      #TODO Confirm your logic for file names will translate to empIDs (must be bullet proof)
      If (($BaseName.length -ge 5) -and ($BaseName -match "^[\d\.]+$")){
        $UserEmpID = [int]$BaseName #cast as integer to strip leading zeroes			 
        $ModDate = $_.LastWriteTime		 
        #fLog $LogPath "File mod date is $ModDate"
        Write-Verbose "File mod date is $ModDate"
      
        $ImageFileContent = $null #reset
        $photo = $null #reset
      
        #TODO dont forget to use -GT here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
         If ($ModDate -lt $FileDateToCompare){		 # USE -GT
           #fLog $LogPath "File mod date is $ModDate"
           Write-Verbose 'Image meets timestamp requirements - proceed with inspection'
           #convert the image file for inspection
           #$ImageFileContent = [byte[]]( Get-Content $ImageFile -encoding byte ) # this method too slow!
           $ImageFileContent = [System.IO.File]::ReadAllBytes($ImagePath+$ImageFileName)
        
           #begin by reading file size
           $FileSize = $ImageFileContent.Length
           #TODO Get agreement from team on the max size
           if ($FileSize -gt 30720) { #max size allowed? using 30kb as example
             #fLog $LogPath "File mod date is $ModDate"
             Write-Verbose "Image larger that 30k - size is $FileSize"
             #read the photo
             Add-Type -AssemblyName System.Drawing
             $stream1 = New-Object System.IO.MemoryStream @(,$ImageFileContent)
             $stream2 = New-Object System.IO.MemoryStream #empty bucket for resizing image
             $image1  = [System.Drawing.Bitmap]::FromStream($stream1)
             $width1  = $image1.Width
             $height1 = $image1.Height
             #fLog $LogPath "File mod date is $ModDate"
             Write-Verbose 'Checking image dimensions'
          
             #read picture height/width	 
             if (($width1 -gt 200) -or ($height1 -gt 200)) { # assuming 200/200
               #fLog $LogPath "File mod date is $ModDate"
               Write-Verbose "Dimensions are $width1 x $height1 - rescale to 200x200"
               $times = $image1.Width / 200
               [int]$width2 = $width1/$times
               [int]$height2 = $height1/$times
            
               $image2 = New-Object System.Drawing.Bitmap $width2,$height2
               $gr = [System.Drawing.Graphics]::FromImage($image2)
               $gr.DrawImage($image1,0,0,$width2,$height2)
               $image2.Save($stream2,[System.Drawing.Imaging.ImageFormat]::Jpeg)
               $photo = $stream2.ToArray() #final product				
            
               Write-Verbose 'Image reconstructed'
               #fLog $LogPath "File mod date is $ModDate"
             } else {#fLog $LogPath 'Image meets dimension requirements - let it pass through' 
               Write-Verbose 'Image meets dimension requirements - let it pass through'
             }
          
             if(-not $photo){$photo = $ImageFileContent}
             Set-ADPicture $UserEmpID $photo		
          
           } else {
             Write-Verbose "File size is approved - size is $FileSize"
             #fLog $LogPath "File mod date is $ModDate"
             Set-ADPicture $UserEmpID $ImageFileContent	
           }
         }				
      }	else {
        Write-Verbose 'File did not meet requirements for update'
        #fLog $LogPath 'File did not meet requirements for update'
        New-ErrorHistory $ImageFileName 'Bad File Type'
      }
      # sleep -Seconds 5
      #fLog $LogPath '*******************************'
    }
  }
  
  end
  {
    #cleanup
    $ImageFileContent = $photo = $stream1  = $stream2 = $image1 = $image2 = $gr = $null 
  
    #Finish up with alerts 
    Send-ITAlert
  }
}

#TODO Ask team what the max size should be - up to 100KB is allowable (maybe 30k?)
Set-ADUserPhotos -ImagePath '\\morgannetfiles\mlpictures$\People' -ReportFolder e:\ARSLogs -Verbose