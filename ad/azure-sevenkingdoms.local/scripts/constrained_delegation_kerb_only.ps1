# https://www.thehacker.recipes/ad/movement/kerberos/delegations/constrained#without-protocol-transition
Set-ADComputer -Identity "castelblack$" -ServicePrincipalNames @{Add='HTTP/winterfell.north.sevenkingdoms.local'}
Set-ADComputer -Identity "castelblack$" -Add @{'msDS-AllowedToDelegateTo'=@('HTTP/winterfell.north.sevenkingdoms.local','HTTP/winterfell')}
# Set-ADComputer -Identity "castelblack$" -Add @{'msDS-AllowedToDelegateTo'=@('CIFS/winterfell.north.sevenkingdoms.local','CIFS/winterfell')}