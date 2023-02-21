<#.EXAMPLE:
.\Remove-MSIProduct.ps1 -productName "Google Chrome" -silent

#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$productName,

    [switch]$silent
)

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$logPath = "C:\Temp\Remove-MSIProduct.log"

# Log the start of the script
Add-Content -Path $logPath -Value "$timestamp Starting Remove-MSIProduct with product name '$productName'."
Write-Host "Starting Remove-MSIProduct with product name '$productName'." -ForegroundColor Green

# Search the registry for the product name
$products = Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\", "HKLM:\SOFTWARE\Classes\Installer\Products\", "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" -Recurse |
            ForEach-Object { Get-ItemProperty $_.PsPath } |
            Where-Object { $_.DisplayName -like "*$productName*" -and $_.SystemComponent -ne 1 }

# Log the number of products found
$productsCount = $products.Count
Add-Content -Path $logPath -Value "$timestamp Found $productsCount product(s) with name '$productName'."
Write-Host "Found $productsCount product(s) with name '$productName'." -ForegroundColor Green

# If no products were found, exit the script
if ($productsCount -eq 0) {
    Add-Content -Path $logPath -Value "$timestamp No products found with name '$productName'."
    Write-Host "No products found with name '$productName'." -ForegroundColor Yellow
    exit
}

# Iterate through each product and uninstall it
foreach ($product in $products) {
    $displayName = $product.DisplayName
    $uninstallString = $product.UninstallString
    $guid = $product.PSChildName
    $registryPath = $product.PSParentPath

    # Log the product information
    Add-Content -Path $logPath -Value "$timestamp Product '$displayName' found with GUID '$guid' in '$registryPath'."
    Write-Host "Product '$displayName' found with GUID '$guid' in '$registryPath'." -ForegroundColor Green

    # Confirm deletion unless -silent is specified
    if (!$silent) {
        $message = "Do you want to uninstall product '$displayName' (GUID: $guid) from '$registryPath'?"
        $result = Read-Host -Prompt $message
        if ($result -ne 'y' -and $result -ne 'Y') {
            Write-Host "Skipping product '$displayName'." -ForegroundColor Yellow
            continue
        }
    }

    # Uninstall the product
    try {
        $command = $uninstallString -replace "/I{", "/X{"
        $process = Start-Process -FilePath "msiexec.exe" -ArgumentList "/qn", $command -Wait -NoNewWindow -PassThru
        if ($process.ExitCode -eq 0) {
            Add-Content -Path $logPath -Value "$timestamp Product '$displayName' with GUID '$guid' uninstalled successfully."
            Write-Host "Product '$displayName' with GUID '$guid' uninstalled successfully." -ForegroundColor Green
        } else {
            Add-Content -Path $logPath -Value "$timestamp Failed to uninstall product '$displayName' with GUID '$guid'."
            Write-Host "Failed to uninstall product ' '$displayName' with GUID '$guid'." -ForegroundColor Red
        }
    } catch {
        Add-Content -Path $logPath -Value "$timestamp Failed to uninstall product '$displayName' with GUID '$guid': $_."
        Write-Host "Failed to uninstall product '$displayName' with GUID '$guid': $_." -ForegroundColor Red
    }

    # Delete the registry keys associated with the product
    $regKeys = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\$guid",
               "HKLM:\SOFTWARE\Classes\Installer\Products\$guid",
               "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$guid"
    foreach ($key in $regKeys) {
        if (Test-Path $key) {
            Remove-Item -Path $key -Recurse -Force
            Add-Content -Path $logPath -Value "$timestamp Registry key '$key' deleted."
            Write-Host "Registry key '$key' deleted." -ForegroundColor Green
        } else {
            Add-Content -Path $logPath -Value "$timestamp Registry key '$key' not found."
            Write-Host "Registry key '$key' not found." -ForegroundColor Yellow
        }
    }
}

# Log the end of the script
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Content -Path $logPath -Value "$timestamp Remove-MSIProduct finished."
Write-Host "Remove-MSIProduct finished." -ForegroundColor Green

