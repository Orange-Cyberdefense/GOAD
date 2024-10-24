# https://www.thehacker.recipes/ad/movement/kerberos/delegations/constrained#without-protocol-transition
Set-ADComputer -Identity "castleblack$" -ServicePrincipalNames @{Add='HTTP/winterfell.north.sevenkingdoms.local'}
Set-ADComputer -Identity "castleblack$" -Add @{'msDS-AllowedToDelegateTo'=@('HTTP/winterfell.north.sevenkingdoms.local','HTTP/winterfell')}
# Set-ADComputer -Identity "castleblack$" -Add @{'msDS-AllowedToDelegateTo'=@('CIFS/winterfell.north.sevenkingdoms.local','CIFS/winterfell')}
