$anonymousId = New-Object System.Security.Principal.NTAccount "NT AUTHORITY\ANONYMOUS LOGON"
$secInheritanceAll = [System.DirectoryServices.ActiveDirectorySecurityInheritance] "All"
$Ace = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $anonymousId,"ReadProperty, GenericExecute","Allow",$secInheritanceAll
$Acl = Get-Acl -Path "AD:$($node.DCPathEnd)"
$Acl.AddAccessRule($Ace)
Set-Acl -Path "AD:$($node.DCPathEnd)" -AclObject $Acl