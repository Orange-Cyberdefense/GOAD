Invoke-Item \\Braavos\public

Start-Sleep -Seconds 5

(New-Object -comObject Shell.Application).Windows() | ? { $_.FullName -ne $null} | ? { $_.FullName.toLower().Endswith('\explorer.exe') } | % {  $_.Quit() }

