$reg = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
Set-ItemProperty -Path $reg -Name ProxyServer -Value "x.x.x.x:8080"
Set-ItemProperty -Path $reg -Name ProxyEnable -Value 1
