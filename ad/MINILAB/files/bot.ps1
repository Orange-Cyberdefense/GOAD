$pass=ConvertTo-SecureString '123456789' -AsPlainText -Force;
$creds=New-Object System.Management.Automation.PSCredential ('mini.lab\carol', $pass);
Invoke-Command -Computername ws.mini.lab -ScriptBlock {sleep 30} -Authentication 'Credssp' -Credential $creds