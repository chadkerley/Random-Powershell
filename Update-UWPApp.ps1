<#
.EXAMPLE
.\Update-UWPApp.ps1 -Package "Microsoft.HEIFImageExtensions" -Version "1.0.43341.0" -Path ".\Microsoft.HEIFImageExtensions_1.0.43341.0_x64.appx"
#>

param (
    [string]$Package,
    [string]$Path,
    [string]$Version
)

# Remove all versions of the app that are less than the one we're installing
Get-AppxPackage -Name $Package -AllUsers | Where-Object { $_.Version -lt $Version } | Remove-AppxPackage -AllUsers

# Remove provisioned packages for the old version
Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -eq $Package -and $_.PackageVersion -lt $Version } | Remove-AppxProvisionedPackage -Online

# Install the remediated version of the app for all users
Add-AppxPackage -Path $Path -AllUsers

# Provision the remediated version of the app for any future users
Add-AppxProvisionedPackage -Online -PackagePath $Path

# Check if remediation was successful
$appxPackage = Get-AppxPackage -Name $Package -AllUsers
if ($appxPackage -and $appxPackage.Version -ge $Version) {
    Write-Output "Remediation successful."
    exit 0
} else {
    Write-Output "Remediation failed."
    exit 1
}
