[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$ProductName
)

# Get the 32-bit and 64-bit uninstall registry locations
$uninstall32 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
$uninstall64 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"

# Search the 32-bit and 64-bit uninstall registry locations for the product name
$uninstallKeys = Get-ChildItem $uninstall32,$uninstall64 | Get-ItemProperty | Where-Object {$_.DisplayName -like "*$ProductName*"}

# Extract the GUID from the UninstallString property
$guids = $uninstallKeys | ForEach-Object {
    $uninstallString = $_.UninstallString
    $guidRegex = [regex]"{[A-Fa-f0-9-]+}"
    $guid = $guidRegex.Match($uninstallString).Value
    if ($guid) {
        $guid
    }
}

# Search the win32_product class for the product name
$guids += Get-WmiObject -Class win32_product | Where-Object {$_.Name -like "*$ProductName*"} | Select-Object -ExpandProperty IdentifyingNumber

# Initialize the log file
$logFile = "C:\temp\msizap.log"
"Running MSIZap.exe for product $ProductName..." | Out-File $logFile

# Loop through the GUIDs and run MSIZap.exe for each one
foreach ($guid in $guids) {
    "Removing product with GUID $guid..." | Out-File $logFile -Append
    $msizapArgs = "T[WA!]", $guid
    $msizapProcess = Start-Process -FilePath "msizap.exe" -ArgumentList $msizapArgs -NoNewWindow -PassThru
    if ($msizapProcess.ExitCode -eq 0) {
        "Product with GUID $guid removed successfully." | Out-File $logFile -Append
    }
    else {
        "Error removing product with GUID $guid: Exit code $($msizapProcess.ExitCode)." | Out-File $logFile -Append
    }
}

"Finished running MSIZap.exe for product $ProductName." | Out-File $logFile -Append
