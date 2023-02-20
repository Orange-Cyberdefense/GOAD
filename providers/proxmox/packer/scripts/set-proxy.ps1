$reg = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
Set-ItemProperty -Path $reg -Name ProxyServer -Value "172.18.9.100:8080"
Set-ItemProperty -Path $reg -Name ProxyEnable -Value 1