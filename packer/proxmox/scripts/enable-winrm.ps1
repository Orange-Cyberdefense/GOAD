$NetworkListManager = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))
$Connections = $NetworkListManager.GetNetworkConnections()
$Connections | ForEach-Object { $_.GetNetwork().SetCategory(1) }

Enable-PSRemoting -Force
winrm quickconfig -q
winrm quickconfig -transport:http
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="800"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'
# winrm set winrm/config/listener?Address=*+Transport=HTTP '@{Port="5985"}'
# winrm set winrm/config/listener?Address=*+Transport=HTTPS '@{Port="5986"}'
netsh advfirewall firewall set rule group="Windows Remote Administration" new enable=yes
netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" new enable=yes action=allow
netsh advfirewall firewall set rule name="Windows Remote Management (HTTPS-In)" new enable=yes action=allow
Set-WSManInstance -ResourceURI WinRM/Config/Client -ValueSet @{TrustedHosts="*"}
Set-Service winrm -startuptype "auto"
Restart-Service winrm
