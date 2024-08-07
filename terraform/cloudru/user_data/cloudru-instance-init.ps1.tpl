#ps1

# ansible user creation & winrm setup
net user ${username} ${password} /add /expires:never /y
net localgroup administrators ${username} /add
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$url = "https://raw.githubusercontent.com/ansible/ansible/38e50c9f819a045ea4d40068f83e78adbfaf2e68/examples/scripts/ConfigureRemotingForAnsible.ps1"
$file = "$env:temp\ConfigureRemotingForAnsible.ps1"
(New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
powershell.exe -ExecutionPolicy ByPass -File $file -ForceNewSSLCert

# sysprep to make SIDs unique
cd "C:/Program Files/Cloudbase Solutions/Cloudbase-Init/conf"
start-process -FilePath "C:/Windows/system32/sysprep/sysprep.exe" -ArgumentList "/generalize /oobe /mode:vm /quit /unattend:Unattend.xml" -wait
shutdown -r -f -t 05
