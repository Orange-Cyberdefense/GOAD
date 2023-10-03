echo "Start Sysprep"
cd "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\"
c:\windows\system32\sysprep\sysprep.exe /generalize /oobe /unattend:cloudbase-init-unattend.xml /quit /shutdown