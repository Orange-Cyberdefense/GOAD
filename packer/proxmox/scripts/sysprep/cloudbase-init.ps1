# install Cloudbase-Init
mkdir "c:\setup"
echo "Copy CloudbaseInitSetup_x64.msi"
copy-item "G:\sysprep\CloudbaseInitSetup_x64.msi" "c:\setup\CloudbaseInitSetup_x64.msi" -force

echo "Start process CloudbaseInitSetup_x64.msi"
start-process -FilePath 'c:\setup\CloudbaseInitSetup_x64.msi' -ArgumentList '/qn /l*v C:\setup\cloud-init.log' -Wait
