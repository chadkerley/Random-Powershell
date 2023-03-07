# Set the registry paths for the 32-bit and 64-bit uninstall locations
$uninstallPath32 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
$uninstallPath64 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"

# Get the current date in the format specified (e.g. 20230307)
$date = Get-Date -Format yyyyMMdd

# Get the list of all installed software that has an InstallDate matching the current date
$installedSoftware32 = Get-ItemProperty $uninstallPath32 | Where-Object {$_.InstallDate -eq $date}
$installedSoftware64 = Get-ItemProperty $uninstallPath64 | Where-Object {$_.InstallDate -eq $date}

# Output the list of matching products from the 32-bit registry
Write-Output "Products installed from 32-bit registry:"
foreach ($product in $installedSoftware32) {
    # Get the GUID from the Uninstall string via text manipulation
    $uninstallString = $product.UninstallString
    $guid = $uninstallString.Substring($uninstallString.IndexOf("{"), $uninstallString.IndexOf("}") - $uninstallString.IndexOf("{") + 1)
    Write-Output "GUID: $guid"
    Write-Output "Display Name: $($product.DisplayName)"
    Write-Output "Version: $($product.DisplayVersion)"
    Write-Output ""
}

# Output the list of matching products from the 64-bit registry
Write-Output "Products installed from 64-bit registry:"
foreach ($product in $installedSoftware64) {
    # Get the GUID from the Uninstall string via text manipulation
    $uninstallString = $product.UninstallString
    $guid = $uninstallString.Substring($uninstallString.IndexOf("{"), $uninstallString.IndexOf("}") - $uninstallString.IndexOf("{") + 1)
    Write-Output "GUID: $guid"
    Write-Output "Display Name: $($product.DisplayName)"
    Write-Output "Version: $($product.DisplayVersion)"
    Write-Output ""
}
