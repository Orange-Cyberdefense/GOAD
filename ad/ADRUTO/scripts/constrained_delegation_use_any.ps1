# https://www.thehacker.recipes/ad/movement/kerberos/delegations/constrained#with-protocol-transition
Set-ADUser -Identity "iruka" -ServicePrincipalNames @{Add='eventlog/share.academy.konoha.fire'}
Get-ADUser -Identity "iruka" | Set-ADAccountControl -TrustedToAuthForDelegation $true
Set-ADUser -Identity "iruka" -Add @{'msDS-AllowedToDelegateTo'=@('eventlog/share.academy.konoha.fire','eventlog/share')}
