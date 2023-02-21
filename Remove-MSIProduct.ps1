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
    $guids += Get-ChildItem -Path $path | Where-Object { $_.GetValue("DisplayName") -like "*$productName*" } | ForEach-Object { $_.PSChildName }
}

# Remove the Windows Installer packages and associated registry keys
if ($guids.Count -gt 0) {
    Write-Host "The following products will be removed:" -ForegroundColor Yellow
    Write-Host $guids -ForegroundColor Yellow
    foreach ($guid in $guids) {
        # Get the product name and registry key path for confirmation
        $displayName = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$guid").DisplayName
        $uninstallKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$guid"

        if ($silent) {
            try {
                # Remove the Windows Installer package using PowerShell
                $installer = [WMICLASS]"\\.\ROOT\cimv2:Win32_Product"
                $software = $installer.Get()
                foreach ($app in $software) {
                    if ($app.IdentifyingNumber -eq $guid) {
                        $installer.Uninstall($app.IdentifyingNumber)
                    }
                }

                # Delete the registry keys associated with the MSI package
                Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\$guid" -Recurse -ErrorAction Stop
                Remove-Item -Path "HKLM:\SOFTWARE\Classes\Installer\Products\$guid" -Recurse -ErrorAction Stop
                Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$guid" -Recurse -ErrorAction Stop

                # Log the actions to the log file
                $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                Add-Content -Path "C:\Temp\Remove-MSIProduct.log" -Value "$timestamp Product '$displayName' was uninstalled."

                Write-Host "Product '$displayName' was uninstalled." -ForegroundColor Green
            }
            catch {
                Write-Host "Error: $_" -ForegroundColor Red
            }
        }
        else {
            $confirm = Read-Host "Do you want to proceed with the uninstall of product '$displayName' with registry key path '$uninstallKeyPath'? (Y/N)"
            if ($confirm -eq "Y" -or $confirm -eq "y") {
                try {
                    # Remove the Windows Installer package using PowerShell
                    $installer = [WMICLASS]"\\.\ROOT\cimv2:Win32_Product"
                    $software = $installer.Get()
                    foreach ($app in $software) {
                        if ($app.IdentifyingNumber -eq $guid) {
                            $installer.Uninstall($app.IdentifyingNumber)
                        }
                    }

                    # Delete the registry keys associated with the MSI package
                    if (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\$guid") {
                        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\$guid" -Recurse -ErrorAction Stop
                    }

                    if (Test-Path -Path "HKLM:\SOFTWARE\Classes\Installer\Products\$guid") {
                        Remove-Item -Path "HKLM:\SOFTWARE\Classes\Installer\Products\$guid" -Recurse -ErrorAction Stop
                    }

                    if (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$guid") {
                        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$guid" -Recurse -ErrorAction Stop
                    }

                    # Log the actions to the log file
                    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                    Add-Content -Path "C:\Temp\Remove-MSIProduct.log" -Value "$timestamp Product '$displayName' was uninstalled."

                    Write-Host "Product '$displayName' was uninstalled." -ForegroundColor Green
                }
                catch {
                    Write-Host "Error: $_" -ForegroundColor Red
                }
            }
            else {
                Write-Host "Product '$displayName' was not uninstalled." -ForegroundColor Yellow
            }
        }
    }
}
else {
    Write-Host "No matching products found." -ForegroundColor Yellow
}

