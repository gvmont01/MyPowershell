#http://adadmin.blogspot.com/2009/10/finding-out-what-searchflags-are-set-on.html

$forest = [System.DirectoryServices.ActiveDirectory.forest]::getcurrentforest()
$schema = [System.DirectoryServices.ActiveDirectory.ActiveDirectorySchema]::GetCurrentSchema().GetDirectoryEntry()
$attributes = $schema.psbase.children | where {$_.objectClass -eq 'attributeSchema'}

$collection = @()
foreach ($attr in $attributes){
  $store = '' | select 'Name','lDAPDisplayName','singlevalued','GC','indexed','ContainerIndexing',
    'ANR','PreserveonDelete','CopyonCopy','ToupleIndexing','SubtreeIndexing','Confidential',
    'AttributeAuditing','RODCenabled'
  $ATDE = [adsi]("LDAP://$($attr.distinguishedName)")
  $store.name = $ATDE.Name[0]
  $store.singlevalued = $ATDE.isSingleValued.ToString()
  $store.GC = $ATDE.isMemberOfPartialAttributeSet.ToString()
  [int]$number = $ATDE.searchflags.ToString()
  While ($number -gt 0){
    switch ($number){
      {$_ -ge 512} {$number = $number-512;$store.RODCenabled=$true;break}
      {$_ -ge 256} {$number = $number-256;$store.AttributeAuditing=$true;break}
      {$_ -ge 128} {$number = $number-128;$store.Confidential=$true;break}
      {$_ -ge 64} {$number = $number-64;$store.SubtreeIndexing=$true;break}
      {$_ -ge 32} {$number = $number-32;$store.ToupleIndexing=$true;break}
      {$_ -ge 16} {$number = $number-15;$store.CopyonCopy=$true;break}
      {$_ -ge 8} {$number = $number-8;$store.PreserveonDelete=$true;break}
      {$_ -ge 4} {$number = $number-4;$store.ANR=$true;break}
      {$_ -ge 2} {$number = $number-2;$store.ContainerIndexing=$true;break}
      {$_ -ge 1} {$number = $number-1;$store.indexed=$true;break} 
    }
  }

  $store.lDAPDisplayName = $ATDE.lDAPDisplayName.ToString()
  $collection += $store

}
$collection | Export-Csv "AD_Schema_attribs_Reports-$($forest.name).csv" -NoTypeInformation