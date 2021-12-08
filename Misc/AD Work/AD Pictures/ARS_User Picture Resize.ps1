# *****************************************************************************
# THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
# WARRANTIES OF MERCHANTBILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE
#
# IF YOU WANT THIS FUNCTIONALITY TO BE CONDITIONALLY SUPPORTED,
# PLEASE CONTACT QUEST PROFESSIONAL SERVICES OR CUSTOM DEVELOPMENT.
#
# *****************************************************************************
# This script is a part of User Picture Resize Community Add-on
# *****************************************************************************
#
# (c) Quest Software Corporation, Moscow Office
#

function onPreModify($Request)
{   
#   trap { continue }
   if (IsAttributeModified 'thumbnailPhoto' $Request)
   {
      $data1  = [byte[]](GetAttribute 'thumbnailPhoto' $Request)
      if ($data1.Length -gt 102400)
      {
         Add-Type -AssemblyName System.Drawing
         $stream1 = New-Object System.IO.MemoryStream @(,$data1)
         $stream2 = New-Object System.IO.MemoryStream 
         $image1 = [System.Drawing.Bitmap]::FromStream($stream1)
         $width1 = $image1.Width
         $height1 = $image1.Height
         if (($width1 -gt 200) -or ($height1 -gt 200))
         {
            $times = $image1.Width / 200
            [int]$width2 = $width1/$times
            [int]$height2 = $height1/$times
            $dims = $width2, $height2

            $image2 = New-Object System.Drawing.Bitmap $width2,$height2
            $gr = [System.Drawing.Graphics]::FromImage($image2)
            $gr.DrawImage($image1,0,0,$width2,$height2)
            $image2.Save($stream2,[System.Drawing.Imaging.ImageFormat]::Jpeg)
            $data2 = $stream2.ToArray()
            $Request.Put('thumbnailPhoto',$data2)
         }
      }
   }
}

function onCheckPropertyValues($Request)
{   
#   trap { continue }
   if (IsAttributeModified 'thumbnailPhoto' $Request)
   {
      PutAttribute 'thumbnailPhoto' $null $Request
   }
}