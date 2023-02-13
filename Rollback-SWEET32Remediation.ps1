#Rollback SWEET32 Remediation because reasons

$registryPath = "SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers"

If (!(Test-Path "HKLM:\$registryPath\Triple DES 168")) {
    New-Item -Path "HKLM:\$registryPath\Triple DES 168" -Force | Out-Null
    Set-ItemProperty -Path "HKLM:\$registryPath\Triple DES 168" -Name "Enabled" -Value 1
}

$registryPath = "SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers"
$ciphers = @("RC4 128/128", "RC4 40/128", "RC4 56/128", "RC4 64/128")

foreach ($cipher in $ciphers) {
    If (!(Test-Path "HKLM:\$registryPath\$cipher")) {
        New-Item -Path "HKLM:\$registryPath\$cipher" -Force | Out-Null
    }

    Set-ItemProperty -Path "HKLM:\$registryPath\$cipher" -Name "Enabled" -Value 1
}

$registryPath = "SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols"
$protocols = @("TLS 1.0\Server", "TLS 1.1\Server", "TLS 1.0\Client", "TLS 1.1\Client")

foreach ($protocol in $protocols) {
    If (!(Test-Path "HKLM:\$registryPath\$protocol")) {
        New-Item -Path "HKLM:\$registryPath\$protocol" -Force | Out-Null
    }

    Set-ItemProperty -Path "HKLM:\$registryPath\$protocol" -Name "Enabled" -Value 1
}
