Import-Module ActiveDirectory
$Domain = (gwmi WIN32_ComputerSystem).Domain

#PART 1: set Account lockout policies
Set-ADDefaultDomainPasswordPolicy -Identity $Domain -AuthType Negotiate -LockoutDuration "00:15:00" -LockoutObservationWindow "00:15:00" -LockoutThreshold "5" -ComplexityEnabled $False -ReversibleEncryptionEnabled $False -MinPasswordLength "5" -MaxPasswordAge "10675199.00:00:00"
