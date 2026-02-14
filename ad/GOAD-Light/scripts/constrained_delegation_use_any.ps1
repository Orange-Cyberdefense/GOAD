# https://www.thehacker.recipes/ad/movement/kerberos/delegations/constrained#with-protocol-transition
Get-ADUser -Identity "jon.snow" | Set-ADAccountControl -TrustedToAuthForDelegation $true
Set-ADUser -Identity "jon.snow" -Add @{'msDS-AllowedToDelegateTo'=@('CIFS/winterfell.north.sevenkingdoms.local','CIFS/winterfell')}