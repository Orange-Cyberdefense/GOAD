<powershell>
$adminUsername = "{{ admin_username }}"
$adminPassword = ConvertTo-SecureString "{{ admin_password }}" -AsPlainText -Force
New-LocalUser $adminUsername -Password $adminPassword -FullName $adminUsername -Description "Admin user"
Add-LocalGroupMember -Group "Administrators" -Member $adminUsername
</powershell>