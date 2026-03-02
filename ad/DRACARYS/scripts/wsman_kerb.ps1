Set-ADComputer -Identity "vhagar$" -ServicePrincipalNames @{Add='WSMAN/vhagar.dracarys.lab'}
Set-ADComputer -Identity "vhagar$" -Add @{'msDS-AllowedToDelegateTo'=@('WSMAN/vhagar.dracarys.lab')}
