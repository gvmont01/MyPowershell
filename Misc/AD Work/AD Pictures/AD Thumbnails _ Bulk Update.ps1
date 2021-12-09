#more here -- http://blog.lyon-marrian.com/2013/10/auto-update-ad-pictures-powershell-script/
	
# Dot source the Task and Function Library
#. e:\Scripts\Functions\ARSTaskFunctions.ps1
	
#Load Requested Snapins from FUNCTIONS.PS1
#LoadQADSnapin
	
$ImagePath = 'c:\temp\People\'
$Now = Get-Date 
$FileDateToCompare = ($Now).AddDays(-1)
$LogFileDate = "{0:MMddyyy}" -f $Now
$LogPath = "c:\temp\ADPhotosTask_$LogFileDate.log" #E:\QCLogs\AD Photos\ADPhotosTask_$LogFileDate.log

function Send-ITAlert {
		param ($AlertSubject, $AlertMsg)
		$EmailSubject = "Alert - AD Photo bulk update issue: $AlertSubject"
		$MailTo = "blah blah" 
		$MailFrom = "blah blah"
		Send-MailMessage -To $MailTo -From  $MailFrom -Subject $EmailSubject -Body $AlertMsg -Priority High  -SmtpServer MyRelay	
}
function Set-ADPicture {
	param ($EmployeeID, $UserPhoto)
		#user must be in active status to have their photo updated; set Searchroot param accordingly
		$User = Get-QADUser -SearchRoot 'blah blah' -sl 0  -oa @{employeeID=$EmployeeID} `
						-DontUseDefaultIncludedProperties -WarningAction SilentlyContinue -ErrorAction SilentlyContinue  
		If ($User){
			$UserLogon = "<domain>\{0}" -f $User.samAccountName
			Write-Host "User located in AD - $UserLogon; updating object property"
			Set-QADUser -Identity $UserLogon -ObjectAttributes @{thumbnailPhoto=$UserPhoto}  | Out-Null
		} else{
			Write-Host "$EmployeeID not located in AD"
			#send alert to IDM Team? If so, send hashtable of all accts, or one-by-one?
			$Subject = "User empID $EmployeeID not found in AD"
			$Body = ' '
			#Send-ITAlert $Subject $Body 
		}
}

#fLog $LogPath "Begin processing..."
Get-ChildItem $ImagePath\*.jpg | ForEach-Object {
		 $ImageFileName = $_.name
		 write-host "Processing $ImageFileName"
		 #fLog $LogPath "processing $ImageFileName"
		 [string]$BaseName = $_.BaseName
		 
		 #filter only for those files that have at least 5 chars for name and are numeric in value
		 If (($BaseName.length -ge 5) -and ($BaseName -match "^[\d\.]+$")){
			 $UserEmpID = [int]$BaseName #cast as integer to strip leading zeroes			 
			 $ModDate = $_.LastWriteTime		 
			  write-host "File mod date is $ModDate"
			  
			 #dont forget to use -GT here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! 
			 $ImageFileContent = $null #reset
			 $photo = $null #reset
			 If ($ModDate -lt $FileDateToCompare){		 #continue the image processing    USE -GT
			 		 Write-Host "Image meets timestamp requirements - proceed with inspection"
					 #convert the image file for inspection
				     #$ImageFileContent = [byte[]]( Get-Content $ImageFile -encoding byte ) # this method too slow!
					 $ImageFileContent = [System.IO.File]::ReadAllBytes($ImagePath+$ImageFileName)
					  
					  #photo size/compression filtering needed? Here are some notes on conducting that work
					  #begin by reading file size
					  $FileSize = $ImageFileContent.Length
				      if ($FileSize -gt 30720) { #max size allowed? using 30kb as example
						  		write-host "Image larger that 30k - size is $FileSize"
						         #read the photo
								 Add-Type -AssemblyName System.Drawing
						         $stream1 = New-Object System.IO.MemoryStream @(,$ImageFileContent)
						         $stream2 = New-Object System.IO.MemoryStream #empty bucket for resizing image
						         $image1 = [System.Drawing.Bitmap]::FromStream($stream1)
						         $width1 = $image1.Width
						         $height1 = $image1.Height
								 Write-Host "Checking image dimensions"
								#read picture height/width	 
					       		  if (($width1 -gt 200) -or ($height1 -gt 200))        { # assuming 200/200
								  		Write-Host "Dimensions are $width1 x $height1 - rescale to 200x200"
							            $times = $image1.Width / 200
							            [int]$width2 = $width1/$times
							            [int]$height2 = $height1/$times

							            $image2 = New-Object System.Drawing.Bitmap $width2,$height2
							            $gr = [System.Drawing.Graphics]::FromImage($image2)
							            $gr.DrawImage($image1,0,0,$width2,$height2)
							            $image2.Save($stream2,[System.Drawing.Imaging.ImageFormat]::Jpeg)
							            $photo = $stream2.ToArray() #final product				
										Write-Host 'Image reconstructed'
					       		  } else {Write-Host 'Image meets dimension requirements - let it pass through'}
								  
								 if(-not $photo){$photo = $ImageFileContent}
								 Set-ADPicture  $UserEmpID $photo		
								 
				     	} else {
							Write-Host "File size is approved - size is $FileSize"
							Set-ADPicture  $UserEmpID $ImageFileContent	
						}
			 }				
		 }	else {Write-Host 'File did not meet requirements for update'}
		 sleep -Seconds 5
}  