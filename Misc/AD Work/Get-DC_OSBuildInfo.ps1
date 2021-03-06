#OS SKU data here -- http://msdn.microsoft.com/en-us/library/aa394239(VS.85).aspx

# Jan 2019 -- use 'Get-ComputerOSBuildInformation.ps1' instead of this script for more options!

$now = Get-Date
$LogFileDate = '{0:MMddyyyyhhmmss}' -f $Now 

$servers = Get-QADComputer -SearchRoot '<domain>.net/Domain Controllers' | Select-Object BuildNumber, CSDVersion, CSName, OperatingSystemSKU

foreach ($i in $servers){
  $build    = @{n = 'Build';    e = { $i.BuildNumber } }
  $SPNumber = @{n = 'SPNumber'; e = { $i.CSDVersion } }
  $hostname = @{n = 'HostName'; e = { $i.CSName } }
	
  $sku = @{n = 'SKU'; e = {
	
      switch ($i.OperatingSystemSKU){
        0 {'Undefined'}
        1 {'Ultimate Edition'}
        2 {'Home Basic Edition'}
        3 {'Home Premium Edition'}
        4 {'Enterprise Edition'}
        5 {'Home Basic N Edition'}
        6 {'Business Edition'}
        7 {'Standard Server Edition'}
        8 {'Datacenter Server Edition'}
        9 {'Small Business Server Edition'}
        10 {'Enterprise Server Edition'}
        11 {'Starter Edition'}
        12 {'Datacenter Server Core Edition'}
        13 {'Standard Server Core Edition'}
        14 {'Enterprise Server Core Edition'}
        15 {'Enterprise Server Edition for Itanium-Based Systems'}		
      }
	
    }
  }
	
  Get-WmiObject Win32_OperatingSystem -computer $i | Select-Object $hostname, $build, $SPNumber, Caption, $sku, servicepackmajorversion |
    Export-Csv c:\temp\reports\DC_OS_Report_$LogFileDate.csv -NoTypeInformation -Append
	
} 
