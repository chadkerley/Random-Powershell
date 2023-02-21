
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$ProductName,

    [Parameter(Mandatory)]
    [string]$Computer
)

# Copy msizap.exe to the remote computer
$sourceFile = "C:\Temp\msizap.exe"
$destination = "\\$Computer\c$\temp\msizap.exe"
Copy-Item -Path $sourceFile -Destination $destination -ToSession (New-PSSession -ComputerName $Computer)

$scriptBlock = {
    # Define the product name to search for
    $productName = $using:ProductName

    # Find all installed products that match the product name
    $matchingProducts = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*$productName*" }

    # Iterate through the matching products and zap each one
    foreach ($product in $matchingProducts) {
        $productGuid = $product.IdentifyingNumber
        Write-Host "Zapping product $productGuid: $($Product.Name)"
        & C:\Temp\msizap.exe TP! $productGuid | Out-Null
    }

    # Log changes made to Remove-MSIProduct.log in C:\temp
    $logPath = "C:\temp\Remove-MSIProduct.log"
    $logEntry = "$(Get-Date): Removed $($matchingProducts.Count) products matching '$productName'"
    Add-Content -Path $logPath -Value $logEntry
}

& psexec.exe \\$Computer powershell.exe -ExecutionPolicy Bypass -Command $scriptBlock
