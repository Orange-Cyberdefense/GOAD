$pass = ConvertTo-SecureString 'ufsmcvDaFz1uEqzAtaiL' -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential (
    'dracarys.lab\rhaegal',
    $pass
)

Invoke-Command `
    -ComputerName vhagar.dracarys.lab `
    -Authentication Credssp `
    -Credential $creds `
    -ScriptBlock {
        $kpPath = '"C:\Program Files\KeePass Password Safe 2\KeePass.exe"'
        $dbPath = 'C:\vault.kdbx'
        $masterPassword = 'lj-endlmkfQSLDKPDFNZLEK'
        $openTime = 30

        Write-Host "[*] Start KeePass via cmd pipe"

        cmd /c "echo $masterPassword | $kpPath $dbPath -pw-stdin"

        Write-Host "[+] KeePass started"
        Start-Sleep -Seconds $openTime

        Write-Host "[-] Closing KeePass"
        Get-Process KeePass -ErrorAction SilentlyContinue | Stop-Process -Force
    }
