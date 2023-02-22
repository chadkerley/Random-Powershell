param (
    [Parameter(Mandatory=$true)]
    [string]$ProductName
)

# Copy MSIZap.exe from network location to local machine
$source = "\\network\path\to\MSIZap.exe"
$destination = "C:\temp\MSIZap.exe"
Copy-Item $source $destination

# Retrieve GUIDs and names for products with matching name
$products = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -eq $ProductName}
$guids = $products | ForEach-Object {$_.IdentifyingNumber}
$names = $products | ForEach-Object {$_.Name}

# Check if any GUIDs were found
if ($guids.Count -eq 0) {
    Write-Output "No products found with name '$ProductName'"
    exit
}

# Remove each matching product and store name and GUID in arrays
$removedNames = @()
$removedGuids = @()
foreach ($guid in $guids) {
    $arguments = "T[WA!] {$guid}"
    $result = & "C:\temp\MSIZap.exe" $arguments
    $removedNames += $names[$guids.IndexOf($guid)]
    $removedGuids += $guid
}

# Output lists of products found and removed
Write-Output "Products found with name '$ProductName':"
for ($i = 0; $i -lt $guids.Count; $i++) {
    Write-Output "  Name: $($names[$i]), GUID: $($guids[$i])"
}

Write-Output "Products removed:"
for ($i = 0; $i -lt $removedGuids.Count; $i++) {
    Write-Output "  Name: $($removedNames[$i]), GUID: $($removedGuids[$i])"
}
