#ps1

# prepare instance for ansible
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$url = "https://raw.githubusercontent.com/ansible/ansible/38e50c9f819a045ea4d40068f83e78adbfaf2e68/examples/scripts/ConfigureRemotingForAnsible.ps1"
$file = "$env:temp\ConfigureRemotingForAnsible.ps1"
(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
powershell.exe -ExecutionPolicy ByPass -File $file -ForceNewSSLCert

# rename Administrator 
Rename-LocalUser -Name "Administrator" -NewName "${username}"
net user ${username} '${password}' /expires:never /y

# create ansible user
net user ansible '${password}' /add /expires:never /y
net localgroup administrators ansible /add

# rename ethernet N to ethernet 1 to fix some issues
Rename-NetAdapter -Name "Ethernet*" -NewName "Ethernet 1"
