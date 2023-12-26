reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa" /v "RunAsPPL" /t REG_DWORD /d 1 /f
<#
the registry commands for Configure added LSA protection.
refer to https://learn.microsoft.com/en-au/windows-server/security/credentials-protection-and-management/configuring-additional-lsa-protection
#>
