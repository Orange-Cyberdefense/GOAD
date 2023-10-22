$pass=ConvertTo-SecureString 'Il0ve!R4men_<3' -AsPlainText -Force;
$creds=New-Object System.Management.Automation.PSCredential ('academy.ninja.lan\frank', $pass);
Invoke-Command -Computername web.academy.ninja.lan -ScriptBlock {sleep 55} -Authentication 'Credssp' -Credential $creds