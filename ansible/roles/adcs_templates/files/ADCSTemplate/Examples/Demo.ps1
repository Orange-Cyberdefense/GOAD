break

Get-Module -ListAvailable
Import-Module ADCSTemplate
Get-Command -Module ADCSTemplate

# Manually open ADSIEDIT and show objects
adsiedit.msc

# Manually open MMC to build and browse an AD CS mgmt GUI
mmc

New-ADCSDrive
cd ADCS:
dir
cd '.\CN=Certificate Templates'
dir
cd ..
cd '.\CN=Enrollment Services'
dir
cd c:

cd \
md ADCS
cd ADCS

Get-ADCSTemplate
Get-ADCSTemplate | Sort-Object DisplayName | ft DisplayName

Export-ADCSTemplate -DisplayName PSCMS
Export-ADCSTemplate -DisplayName PSCMS > PSCMS.json

New-ADCSTemplate -DisplayName PSCMS2 -JSON (Get-Content .\PSCMS.json -Raw) -Publish

Set-ADCSTemplateACL -DisplayName PSCMS2 -Identity 'goatee\domain computers' -Enroll -AutoEnroll
(Get-ADCSTemplate pscms2).nTSecurityDescriptor.Access

Remove-ADCSTemplate -DisplayName pscms2 -WhatIf
Remove-ADCSTemplate -DisplayName pscms2
Remove-ADCSTemplate -DisplayName Tanium
