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

# Write to the console and log file that we're starting
Write-Host "Running MSIZap.exe for product $ProductName..."
"Running MSIZap.exe for product $ProductName..." | Out-File $logFile

# Loop through each GUID and run MSIZap.exe
foreach ($guid in $guids) {
    # Build an argument array for MSIZap.exe with the current GUID
    $msizapArgs = @("TW!", $guid)

    # Run MSIZap.exe with the current GUID
    $msizapProcess = Start-Process -FilePath ".\msizap.exe" -ArgumentList $msizapArgs -NoNewWindow -PassThru

    # Check the exit code of MSIZap.exe and write to the console and log file accordingly
    if ($msizapProcess.ExitCode -eq 0) {
        Write-Host "Product with GUID $guid removed successfully."
        "Product with GUID $guid removed successfully." | Out-File $logFile -Append
    }
    else {
        Write-Host "Error removing product with GUID $guid: Exit code $($msizapProcess.ExitCode)."
        "Error removing product with GUID $guid Exit code $($msizapProcess.ExitCode)." | Out-File $logFile -Append
    }
}

# Write to the console and log file that we're finished
Write-Host "MSIZap.exe complete for product $ProductName."
"MSIZap.exe complete for product $ProductName." | Out-File $logFile -Append
