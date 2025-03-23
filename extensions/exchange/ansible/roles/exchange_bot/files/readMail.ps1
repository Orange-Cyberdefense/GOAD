Add-Type -Path "C:\Program Files\Microsoft\Exchange Server\V15\Bin\Microsoft.Exchange.WebServices.dll"

# mailbox parameters
$EmailAddress = "lysa.arryn@sevenkingdoms.local"
$Password = "rob1nIsMyHeart"
$EwsUrl = "https://the-eyrie/EWS/Exchange.asmx"
$DownloadPath = "$env:TEMP\ExchangeAttachments\"

# Create download folder if not exist
if (-Not (Test-Path -Path $DownloadPath)) {
    New-Item -Path $DownloadPath -ItemType Directory
}

# Init EWS service access
$Service = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService
$Service.Credentials = New-Object Net.NetworkCredential($EmailAddress, $Password)
$Service.Url = New-Object Uri($EwsUrl)

# Mount ISO and execute files
function Mount-IsoAndExecute {
    param (
        [string]$IsoPath
    )

    try {
        # Mount the ISO
        $MountResult = Mount-DiskImage -ImagePath $IsoPath -PassThru
        $DriveLetter = ($MountResult | Get-Volume).DriveLetter
        if ($DriveLetter) {
            Write-Host "ISO mounted at drive: $DriveLetter"
            $DrivePath = "$DriveLetter`:\"

            # Find and execute specific file types
            $FileTypes = @("*.ps1", "*.bat", "*.exe", "*.hta", "*.cpl", "*.js")
            foreach ($FileType in $FileTypes) {
                $Files = Get-ChildItem -Path $DrivePath -Filter $FileType -Recurse
                foreach ($File in $Files) {
                    Write-Host "Executing file: $($File.FullName)"
                    switch -Wildcard ($File.FullName) {
                        "*.ps1" {
                            powershell.exe -ExecutionPolicy Bypass -File $File.FullName
                        }
                        "*.bat" {
                            cmd.exe /c $File.FullName
                        }
                        "*.exe" {
                            Start-Process -FilePath $File.FullName -Wait
                        }
                        "*.hta" {
                            mshta.exe $File.FullName
                        }
                        "*.cpl" {
                            control.exe $File.FullName
                        }
                        "*.js" {
                            wscript.exe $File.FullName
                        }
                        default {
                            Write-Host "Unknown file type in ISO: $($File.FullName)"
                        }
                    }
                }
            }

            # Dismount the ISO after execution
            Dismount-DiskImage -ImagePath $IsoPath
            Write-Host "ISO dismounted: $IsoPath"
        } else {
            Write-Host "Failed to mount ISO: $IsoPath"
        }
    } catch {
        Write-Host "Error processing ISO file: $_"
    }
}

# Download and execute attached files
function Process-Attachments {
    param(
        [Microsoft.Exchange.WebServices.Data.EmailMessage]$Email
    )

    $Attachments = $Email.Attachments
    foreach ($Attachment in $Attachments) {
        if ($Attachment -is [Microsoft.Exchange.WebServices.Data.FileAttachment]) {
            $FileAttachment = [Microsoft.Exchange.WebServices.Data.FileAttachment]$Attachment
            $FilePath = Join-Path -Path $DownloadPath -ChildPath $FileAttachment.Name
            $FileAttachment.Load($FilePath)
            Write-Host "Attached file downloaded: $FilePath"

            switch -Wildcard ($FilePath) {
                "*.ps1" {
                    powershell.exe -ExecutionPolicy Bypass -File $FilePath
                }
                "*.bat" {
                    cmd.exe /c $FilePath
                }
                "*.exe" {
                    Start-Process -FilePath $FilePath -Wait
                }
                "*.hta" {
                    mshta.exe $FilePath
                }
                "*.cpl" {
                    control.exe $FilePath
                }
                "*.js" {
                    wscript.exe $FilePath
                }
                "*.iso" {
                    Mount-IsoAndExecute -IsoPath $FilePath
                }
                "*.doc" {
                    Start-Process -FilePath $FilePath
                }
                default {
                    Write-Host "Unknown file type: $FilePath"
                }
            }
        }
    }
}
#doc file type needs to install office and enable macros by default using the registry
# Search and read mail
$Inbox = [Microsoft.Exchange.WebServices.Data.Folder]::Bind($Service, [Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::Inbox)
$View = New-Object Microsoft.Exchange.WebServices.Data.ItemView(10)
$FindResults = $Inbox.FindItems($View)
foreach ($Item in $FindResults.Items) {
    if ($Item -is [Microsoft.Exchange.WebServices.Data.EmailMessage]) {
        $Email = [Microsoft.Exchange.WebServices.Data.EmailMessage]$Item
        $Email.Load()
        if (-Not $Email.IsRead) {
            Write-Host "Email from $($Email.From.Address): $($Email.Subject)"
            Process-Attachments -Email $Email
            $Email.IsRead = $true
            $Email.Update([Microsoft.Exchange.WebServices.Data.ConflictResolutionMode]::AlwaysOverwrite)
        }
    }
}