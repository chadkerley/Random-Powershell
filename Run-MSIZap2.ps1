param (
    [string]$ProductName
)

# Copy MSIZap.exe from network location to local machine
$source = "\\network\path\to\MSIZap.exe"
$destination = "C:\temp\MSIZap.exe"
Copy-Item $source $destination

# Retrieve GUIDs for products with matching name
$products = Get-WmiObject -Class Win32_Product | Where-Object {$_.Name -eq $ProductName}
$guids = $products | ForEach-Object {$_.IdentifyingNumber}

# Run MSIZap.exe for each matching product
foreach ($guid in $guids) {
    $arguments = "T[WA!] {$guid}"
    & "C:\temp\MSIZap.exe" $arguments
}
