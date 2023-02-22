[CmdletBinding()]
Param (
    [Parameter(Mandatory=$True)]
    [string]$ProductName,
    [Parameter(Mandatory=$True)]
    [string]$Computer
)

# Write progress to console and log file
function Write-ProgressLog($Message)
{
    Write-Host $Message
    Add-Content $LogFilePath $Message
}

# Set log file path
$LogFilePath = "\\$Computer\c$\temp\Remove-$ProductName.log"

# Get 32-bit and 64-bit GUIDs using Win32_Product
$Products = Get-WmiObject -Class Win32_Product -ComputerName $Computer | Where-Object {$_.Name -like "*$ProductName*"}
$Guids = @()
foreach ($Product in $Products) {
    $Guids += $Product.IdentifyingNumber
}

# Write found products and GUIDs to log file
Write-ProgressLog "`nFound the following products and GUIDs:`n"
foreach ($Guid in $Guids) {
    $Product = ($Products | Where-Object {$_.IdentifyingNumber -eq $Guid}).Name
    Write-ProgressLog "Product: $Product"
    Write-ProgressLog "GUID: $Guid`n"
}

# Remove products with MSIZap
if ($Guids.Count -gt 0) {
    Write-ProgressLog "`nRemoving products..."
    $PsExec = "\\$Computer\c$\tools\pstools\psexec.exe"
    $MSIZap = "\\$Computer\c$\temp\MSIZap.exe"
    foreach ($Guid in $Guids) {
        # Remove 32-bit version of product
        $Status = & $PsExec \\$Computer -s -accepteula $MSIZap tw! {$Guid} 2>&1
        Write-ProgressLog "Removing 32-bit version of $ProductName with GUID ${Guid} from $Computer: $Status"

        # Remove 64-bit version of product
        $Status = & $PsExec -s -accepteula \\$Computer $env:windir\sysnative\MSIZap.exe tw! {$Guid} 2>&1
        Write-ProgressLog "Removing 64-bit version of $ProductName with GUID ${Guid} from $Computer: $Status"
    }
} else {
    Write-ProgressLog "`nNo products found matching $ProductName."
}
