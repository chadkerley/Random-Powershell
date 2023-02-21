<#.EXAMPLE:
.\Remove-MSIProduct.ps1 -productName "Google Chrome" -silent

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$productName,

    [switch]$silent
)

# Define the registry paths to search
$registryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

# Search for matching products and retrieve the GUIDs
$guids = @()
foreach ($path in $registryPaths) {
    $guids += Get-ChildItem -Path $path | Where-Object { $_.GetValue("DisplayName") -like "*$productName*" } | ForEach-Object { $_.Name }
}

# Remove the Windows Installer packages and associated registry keys
if ($guids.Count -gt 0) {
    Write-Host "The following products will be removed:" -ForegroundColor Yellow
    Write-Host $guids -ForegroundColor Yellow
    if ($silent) {
        foreach ($guid in $guids) {
            # Remove the Windows Installer package using PowerShell
            $installer = [WMICLASS]"\\.\ROOT\cimv2:Win32_Product"
            $software = $installer.Get()
            foreach ($app in $software) {
                if ($app.IdentifyingNumber -eq $guid) {
                    $installer.Uninstall($app.IdentifyingNumber)
                }
            }

            # Delete the registry keys associated with the MSI package
            Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\$guid" -Recurse
            Remove-Item -Path "HKLM:\SOFTWARE\Classes\Installer\Products\$guid" -Recurse
            Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$guid" -Recurse
        }
        Write-Host "Uninstallation complete." -ForegroundColor Green
    }
    else {
        $confirm = Read-Host "Do you want to proceed with the uninstall? (Y/N)"
        if ($confirm -eq "Y" -or $confirm -eq "y") {
            foreach ($guid in $guids) {
                # Remove the Windows Installer package using PowerShell
                $installer = [WMICLASS]"\\.\ROOT\cimv2:Win32_Product"
                $software = $installer.Get()
                foreach ($app in $software) {
                    if ($app.IdentifyingNumber -eq $guid) {
                        $installer.Uninstall($app.IdentifyingNumber)
                    }
                }

                # Delete the registry keys associated with the MSI package
                Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\$guid" -Recurse
                Remove-Item -Path "HKLM:\SOFTWARE\Classes\Installer\Products\$guid" -Recurse
                Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$guid" -Recurse
            }
            Write-Host "Uninstallation complete." -ForegroundColor Green
        }
        else {
            Write-Host "Uninstallation cancelled." -ForegroundColor Red
        }
    }
}
else {
    Write-Host "No products found with the name '$productName'." -ForegroundColor Yellow
}
