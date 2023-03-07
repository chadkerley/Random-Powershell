$installDate = Get-Date -Format yyyyMMdd
$uninstallKeys32 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
$uninstallKeys64 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"

# Get products installed today from 32-bit uninstall keys
$products32 = Get-ChildItem $uninstallKeys32 | foreach {
    if (($_.GetValue("InstallDate") -eq $installDate) -and ($_.GetValue("DisplayName") -ne $null)) {
        $displayName = $_.GetValue("DisplayName")
        $guid = $_.GetValue("PSChildName")
        $version = $_.GetValue("DisplayVersion")
        [PSCustomObject]@{
            DisplayName = $displayName
            GUID = $guid
            Version = $version
        }
    }
}

# Get products installed today from 64-bit uninstall keys
$products64 = Get-ChildItem $uninstallKeys64 | foreach {
    if (($_.GetValue("InstallDate") -eq $installDate) -and ($_.GetValue("DisplayName") -ne $null)) {
        $displayName = $_.GetValue("DisplayName")
        $guid = $_.GetValue("PSChildName")
        $version = $_.GetValue("DisplayVersion")
        [PSCustomObject]@{
            DisplayName = $displayName
            GUID = $guid
            Version = $version
        }
    }
}

# Output results
if ($products32.Count -gt 0) {
    Write-Host "Products installed today from 32-bit uninstall keys:"
    $products32 | ft -AutoSize
}
if ($products64.Count -gt 0) {
    Write-Host "Products installed today from 64-bit uninstall keys:"
    $products64 | ft -AutoSize
}
if (($products32.Count -eq 0) -and ($products64.Count -eq 0)) {
    Write-Host "No products installed today."
}
