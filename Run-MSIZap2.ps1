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

# Define path to tools
$PsExec = "C:\tools\pstools\psexec.exe"
$MSIZap = "C:\temp\MSIZap.exe"

#Copy MSIZap to remote computer
Write-Output "Copying MSIZap.exe into C:\temp on $Computer"
Copy-Item -Path "$MSIZap" -Destination (New-Item \\$Computer\C$\Temp -Type Container -Force) -Recurse -Force

Write-ProgressLog "`nFinding products on $Computer..."

# Run the command on the remote machine using PsExec
$Command = "Get-WmiObject -Class Win32_Product | Where-Object {`$_.Name -like `"`*$ProductName*`"`} | Select-Object -ExpandProperty IdentifyingNumber"
$Guids = & $PsExec \\$Computer -s -accepteula powershell.exe -Command $Command

# If no products are found, log the message and exit
if ($Guids -eq $null) {
    Write-ProgressLog "`nNo products found matching $ProductName on $Computer."
    return
}

# Write found products and GUIDs to log file
Write-ProgressLog "`nFound the following products and GUIDs:`n"
foreach ($Guid in $Guids) {
    $Command = "Get-WmiObject -Class Win32_Product | Where-Object {`$_.IdentifyingNumber -eq `"$Guid`"} | Select-Object -ExpandProperty Name"
    $Product = & $PsExec \\$Computer -s -accepteula powershell.exe -Command $Command
    Write-ProgressLog "Product: $Product"
    Write-ProgressLog "GUID: $Guid`n"
}

# Remove products with MSIZap
Write-ProgressLog "`nRemoving products..."
foreach ($Guid in $Guids) {
    # Remove 32-bit version of product
    $Status = & $PsExec \\$Computer -s -accepteula C:\temp\MSIZap.exe tw! {$Guid} 2>&1
    Write-ProgressLog "Removing 32-bit version of $ProductName with GUID {$Guid} from $Computer $Status"

    # Remove 64-bit version of product
    $Status = & $PsExec \\$Computer -s -accepteula C:\temp\MSIZap.exe tw64! {$Guid} 2>&1
    Write-ProgressLog "Removing 64-bit version of $ProductName with GUID {$Guid} from $Computer $Status"
}
