[CmdletBinding()]
Param (
    [Parameter(Mandatory=$True)]
    [string]$ProductName,

    [Parameter(Mandatory=$True)]
    [string]$Computer
)

# Write progress to console and log file
function Write-ProgressLog($Message) {
    Write-Host $Message
    Add-Content $LogFilePath $Message
}

# Set log file path
$LogFilePath = "\\$Computer\c$\temp\Remove-$ProductName.log"

# Get 32-bit and 64-bit GUIDs using the registry
$32BitKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall"
$64BitKey = "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"

$Guids = Get-ChildItem $32BitKey, $64BitKey | 
    Get-ItemProperty | 
    Where-Object { $_.DisplayName -like "*$ProductName*" } | 
    Select-Object -ExpandProperty UninstallString | 
    ForEach-Object {
        # Parse the GUID from the uninstall string
        if ($_ -match ".*\{(.*)\}.*") {
            $matches[1]
        }
    }

# If no products are found, log the message and exit
if ($Guids -eq $null) {
    Write-ProgressLog "`nNo products found matching $ProductName on $Computer."
    return
}

# Write found products and GUIDs to log file
Write-ProgressLog "`nFound the following products and GUIDs:`n"
foreach ($Guid in $Guids) {
    Write-ProgressLog "GUID: $Guid`n"
}

# Remove products with MSIZap
Write-ProgressLog "`nRemoving products..."
foreach ($Guid in $Guids) {
    # Remove 32-bit version of product
    $Status = & $PsExec \\$Computer -s -accepteula C:\temp\MSIZap.exe tw! $Guid 2>&1
    Write-ProgressLog "Removing 32-bit version of $ProductName with GUID $Guid from $Computer $Status"

    # Remove 64-bit version of product
    $Status = & $PsExec \\$Computer -s -accepteula C:\temp\MSIZap.exe tw64! $Guid 2>&1
    Write-ProgressLog "Removing 64-bit version of $ProductName with GUID $Guid from $Computer $Status"
}
