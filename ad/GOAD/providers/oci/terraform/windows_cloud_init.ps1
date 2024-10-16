<powershell>
# Variables
$adminUsername = "ansible"
$adminPassword = ConvertTo-SecureString "YourSecurePassword123!" -AsPlainText -Force

# Create ansible user
New-LocalUser $adminUsername -Password $adminPassword -FullName $adminUsername -Description "Ansible admin user"
Add-LocalGroupMember -Group "Administrators" -Member $adminUsername

# Enable WinRM
winrm quickconfig -q
winrm set winrm/config/service/auth @{Basic="true"}
winrm set winrm/config/service @{AllowUnencrypted="true"}
winrm set winrm/config/service @{EnableCompatibilityHttpsListener="true"}
winrm set winrm/config/service @{EnableCompatibilityHttpListener="true"}
$cert = New-SelfSignedCertificate -DnsName $(hostname) -CertStoreLocation Cert:\LocalMachine\My
winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname=$(hostname); CertificateThumbprint=$($cert.Thumbprint)}
Set-Service -Name winrm -StartupType Automatic
Start-Service -Name winrm

# Enable basic authentication and unencrypted traffic for WinRM
Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $true
Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $true

# Configure WinRM firewall exception
New-NetFirewallRule -Name "WinRM-HTTP" -DisplayName "WinRM (HTTP-In)" -Protocol TCP -LocalPort 5985 -Action Allow -Enabled True
New-NetFirewallRule -Name "WinRM-HTTPS" -DisplayName "WinRM (HTTPS-In)" -Protocol TCP -LocalPort 5986 -Action Allow -Enabled True

# Set the TLS 1.2 protocol
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Install NuGet provider and update PowerShellGet
Install-PackageProvider -Name NuGet -Force -Confirm:$false
Update-Module -Name PowerShellGet -Force -AllowClobber -Confirm:$false
</powershell>