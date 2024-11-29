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

# download and execute attached files
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
            Write-Host "attached file downloaded : $FilePath"


            switch -Wildcard ($FilePath) {
                "*.ps1" {
                    powershell.exe -ExecutionPolicy Bypass -File $FilePath
                }
                "*.bat" {
                    cmd.exe /c $FilePath
                }
                "*.exe" {
                    $FilePath
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
                default {
                    Write-Host "unknow type file : $FilePath"
                }
            }
        }
    }
}

# Search and read mail
$Inbox = [Microsoft.Exchange.WebServices.Data.Folder]::Bind($Service, [Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::Inbox)
$View = New-Object Microsoft.Exchange.WebServices.Data.ItemView(10) # get last 10 emails
$FindResults = $Inbox.FindItems($View)
foreach ($Item in $FindResults.Items) {
    if ($Item -is [Microsoft.Exchange.WebServices.Data.EmailMessage]) {
        $Email = [Microsoft.Exchange.WebServices.Data.EmailMessage]$Item
        $Email.Load()
        if (-Not $Email.IsRead) {
            Write-Host "Email de $($Email.From.Address): $($Email.Subject)"
            Process-Attachments -Email $Email
            $Email.IsRead = $true
            $Email.Update([Microsoft.Exchange.WebServices.Data.ConflictResolutionMode]::AlwaysOverwrite)
        }
    }
}