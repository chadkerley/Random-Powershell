<#
.SYNOPSIS
Removes a specified product from a remote computer using MSIZap.

.DESCRIPTION
This script copies MSIZap.exe to a remote computer, finds the GUIDs for all products matching a specified name, and uses MSIZap to completely remove the matching products. It logs the product name, GUIDs, and success or errors to a log file in C:\temp on the remote computer.

.PARAMETER ProductName
The name of the product to be removed.

.PARAMETER Computer
The name of the remote computer.

.EXAMPLE
.\Remove-Product.ps1 -ProductName "Google Chrome" -Computer "remote-computer"

This command removes the product "Google Chrome" from the computer "remote-computer".

.NOTES
Date: 2/21/23
#>

Param(
    [Parameter(Mandatory=$true)]
    [string]$ProductName,
    
    [Parameter(Mandatory=$true)]
    [string]$Computer
)

# Define the paths for MSIZap.exe and psexec.exe
$MSIZapPath = "C:\tools\MSIZap.exe"
$psexecPath = "C:\tools\pstools\psexec.exe"

# Define the destination folder for MSIZap.exe on the remote computer
$destinationFolder = "\\$Computer\c$\temp"

# Create the log file path and header
$logFilePath = "$destinationFolder\Remove-$ProductName.log"
$logHeader = "Product Name, GUID, Status`n"

# Initialize the log file with the header
$logHeader | Out-File -FilePath $logFilePath -Encoding ascii

# Copy MSIZap.exe to the remote computer
Write-Host "Copying MSIZap.exe to $destinationFolder"
Copy-Item $MSIZapPath $destinationFolder

# Find the GUIDs for all products matching the provided product name on the remote computer
Write-Host "Finding GUIDs for $ProductName on $Computer"
$productGuids = & $psexecPath \\$Computer powershell.exe -Command "Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -eq '$ProductName'} | ForEach-Object {Write-Output $_.PSChildName}"

# Use MSIZap to completely remove all products with the matching GUIDs
foreach ($guid in $productGuids) {
    Write-Host "Removing product $ProductName with GUID $guid from $Computer"
    $status = & $psexecPath \\$Computer cmd /c "$destinationFolder\MSIZap.exe tw! {$guid} 2>&1"
    $logLine = "$ProductName, $guid, $status`n"
    $logLine | Out-File -FilePath $logFilePath -Encoding ascii -Append
    if ($status -match "error") {
        Write-Host "Error removing product $ProductName with GUID $guid from $Computer: $status"
    } else {
        Write-Host "Product $ProductName with GUID $guid was successfully removed from $Computer"
    }
}
