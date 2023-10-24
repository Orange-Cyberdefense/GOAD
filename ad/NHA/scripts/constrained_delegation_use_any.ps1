# https://www.thehacker.recipes/ad/movement/kerberos/delegations/constrained#with-protocol-transition
Set-ADUser -Identity "frank" -ServicePrincipalNames @{Add='eventlog/share.academy.ninja.lan'}
Get-ADUser -Identity "frank" | Set-ADAccountControl -TrustedToAuthForDelegation $true
Set-ADUser -Identity "frank" -Add @{'msDS-AllowedToDelegateTo'=@('eventlog/share.academy.ninja.lan','eventlog/share')}
