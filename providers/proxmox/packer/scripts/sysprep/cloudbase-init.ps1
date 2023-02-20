# install Cloudbase-Init
mkdir "c:\setup"
echo "Copy CloudbaseInitSetup_1_1_2_x64"
copy-item "G:\sysprep\CloudbaseInitSetup_1_1_2_x64.msi" "c:\setup\CloudbaseInitSetup_1_1_2_x64.msi" -force

echo "Start process CloudbaseInitSetup_1_1_2_x64"
start-process -FilePath 'c:\setup\CloudbaseInitSetup_1_1_2_x64.msi' -ArgumentList '/qn /l*v C:\setup\cloud-init.log' -Wait