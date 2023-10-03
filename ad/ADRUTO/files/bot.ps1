$pass=ConvertTo-SecureString 'Il0ve!R4men_<3' -AsPlainText -Force;
$creds=New-Object System.Management.Automation.PSCredential ('academy.konoha.fire\iruka', $pass);
Invoke-Command -Computername web.academy.konoha.fire -ScriptBlock {sleep 55} -Authentication 'Credssp' -Credential $creds