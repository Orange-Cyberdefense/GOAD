while (!(Select-String -Path 'C:\setup\cloud-init.log' -Pattern 'Installation completed successfully' -Quiet)) {
    echo "Wait cloud-init installation end..."
    Start-Sleep 5
}

echo "Show cloudinit service"
Get-Service -Name cloudbase-init

echo "Move config files to location"
# Move conf files to Cloudbase directory
copy-item "G:\sysprep\cloudbase-init.conf" "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init.conf" -force
copy-item "G:\sysprep\cloudbase-init-unattend.conf" "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init-unattend.conf" -force
copy-item "G:\sysprep\cloudbase-init-unattend.xml" "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init-unattend.xml" -force

# Delete cloudbase-init User
net user cloudbase-init /delete

# Attribute service to local system
sc.exe config cloudbase-init obj= .\LocalSystem

# Modify executon path of Service
$newtext = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\cloudbase-init' -Name 'ImagePath' | Select-Object -ExpandProperty ImagePath | %{$_.replace(" cloudbase-init ", " NT-AUTHORITY\SYSTEM ")}
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\cloudbase-init' -Name 'ImagePath' -Value $newtext

echo "Running Sysprep"
# Run sysprep
cd "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\"
start-process -FilePath "C:/Windows/system32/sysprep/sysprep.exe" -ArgumentList "/generalize /oobe /mode:vm /quit /unattend:cloudbase-init-unattend.xml" -wait
