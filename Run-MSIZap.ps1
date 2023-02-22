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
.\Remove-Product.ps1 -ProductName "Google Chrome" -Computer "computername"

This command removes the product "Google Chrome" from the computer "computername".

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
Copy-Item $MSIZapPath $destinationFolder

# Find the GUIDs for all products matching the provided product name on the remote computer
$productGuids = & $psexecPath \\$Computer powershell.exe -Command "$ProductList = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -eq '$ProductName'}; $ProductList | ForEach-Object {Write-Output $_.IdentifyingNumber}"

# Use MSIZap to completely remove all products with the matching GUIDs
foreach ($guid in $productGuids) {
    $status = & $psexecPath \\$Computer cmd /c "$destinationFolder\MSIZap.exe tw! {$guid} 2>&1"
    $logLine = "$ProductName, $guid, $status`n"
    $logLine | Out-File -FilePath $logFilePath -Encoding ascii -Append
}
