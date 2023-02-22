param (
    [Parameter(Mandatory=$true)]
    [string]$ProductName
)

# Initialize variables
$uninstallRegistryLocations = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)
$guids = @()
$logFile = "C:\temp\msizap_log.txt"
$msizapPath = ".\msizap.exe"

# Search registry uninstall keys for the provided product name
foreach ($location in $uninstallRegistryLocations) {
    $uninstallKeys = Get-ChildItem $location | ForEach-Object {Get-ItemProperty $_.PSPath} | Where-Object {$_.DisplayName -like "*$ProductName*"}
    foreach ($key in $uninstallKeys) {
        # Extract the GUID from the uninstall key and add it to the array of GUIDs
        if ($key.PSChildName -match "^\{.*\}$") {
            $guids += $matches[0]
            Write-Host "Found GUID $($matches[0]) in $($key.PSPath)" # Write to console
            Add-Content $logFile "$(Get-Date) : Found GUID $($matches[0]) in $($key.PSPath)" # Write to log file
        }
    }
}

# Search Win32_Product WMI class for the provided product name
$win32Product = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -like "*$ProductName*"}
if ($win32Product) {
    $guids += $win32Product.IdentifyingNumber
    Write-Host "Found GUID $($win32Product.IdentifyingNumber) in Win32_Product WMI class" # Write to console
    Add-Content $logFile "$(Get-Date) : Found GUID $($win32Product.IdentifyingNumber) in Win32_Product WMI class" # Write to log file
}

# Remove duplicates from the array of GUIDs
$guids = $guids | Select-Object -Unique

# Run MSIZAP for each GUID in the array
foreach ($guid in $guids) {
    $msizapArgs = "TW! {$guid}"
    Write-Host "Running MSIZAP with arguments $msizapArgs" # Write to console
    Add-Content $logFile "$(Get-Date) : Running MSIZAP with arguments $msizapArgs" # Write to log file
    Start-Process -FilePath $msizapPath -ArgumentList $msizapArgs -Wait -NoNewWindow
}

# Write to the console and log file that we're finished
Write-Host "Finished removing GUIDs for $ProductName" # Write to console
Add-Content $logFile "$(Get-Date) : Finished removing GUIDs for $ProductName" # Write to log file
