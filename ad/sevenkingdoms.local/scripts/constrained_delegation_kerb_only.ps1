# https://www.thehacker.recipes/ad/movement/kerberos/delegations/constrained#without-protocol-transition
Set-ADUser -Identity "svc_file_kerb" -ServicePrincipalNames @{Add='CIFS/DB01.bs.corp'}
Set-ADUser -Identity "svc_file_kerb" -Add @{'msDS-AllowedToDelegateTo'=@('CIFS/DB01.bs.corp')}