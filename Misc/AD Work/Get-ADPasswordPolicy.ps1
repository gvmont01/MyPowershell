function LoadADModule {
  # Load AD Module (if not already)
  if ((Get-Module ActiveDirectory -ErrorAction SilentlyContinue) -eq $null){
    Import-Module ActiveDirectory
  }
}
 #region OPTION 1
LoadADModule

Get-ADDefaultDomainPasswordPolicy '<domain>.com' -Server 'bos1'

#another option using QAD cmdlets
#http://blogs.technet.com/b/heyscriptingguy/archive/2014/01/09/use-powershell-to-get-account-lockout-and-password-policy.aspx