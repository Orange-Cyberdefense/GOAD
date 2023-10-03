# install Cloudbase-Init
mkdir "c:\setup"
echo "Copy CloudbaseInitSetup_Stable_x64.msi"
copy-item "G:\sysprep\CloudbaseInitSetup_Stable_x64.msi" "c:\setup\CloudbaseInitSetup_Stable_x64.msi" -force

echo "Start process CloudbaseInitSetup_Stable_x64.msi"
start-process -FilePath 'c:\setup\CloudbaseInitSetup_Stable_x64.msi' -ArgumentList '/qn /l*v C:\setup\cloud-init.log' -Wait
