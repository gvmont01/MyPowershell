function Get-ADSchemaVersion
{
   
  if(-not (get-module activedirectory)) {
    Import-Module activedirectory 
  }   
  
  $SchemaVersion = (Get-ADObject (Get-ADRootDSE).schemaNamingContext -Property objectVersion).objectVersion
  
  switch ($SchemaVersion)
  {
    87 {'Windows Server 2016'}
    69 {'Windows Server 2012 R2'}
    56 {'Windows Server 2012'}
    47 {'Windows Server 2008 R2'}
    44 {'Windows Server 2008'}
    31 {'Windows Server 2003 R2'}
    30 {'Windows Server 2003'}
    13 {'Windows 2000'}  
  }
}

Get-ADSchemaVersion