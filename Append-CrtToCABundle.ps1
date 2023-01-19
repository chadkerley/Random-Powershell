function Append-CrtToCABundle {
    <#
    .SYNOPSIS
        Appends a .crt file to the end of a .crt file (ca-bundle.crt)
    .DESCRIPTION
        This function will append a .crt file to the end of a .crt file (ca-bundle.crt), after checking if the certificate is already present in the ca-bundle.crt
    .PARAMETER CabundlePath
        The path of the ca-bundle.crt file
    .PARAMETER CertPath
        The path of the certificate file
    .EXAMPLE
        Append-CrtToCABundle -CabundlePath "c:\path\to\ca-bundle.crt" -CertPath "c:\path\to\cert.crt"
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true,Position=1)]
        [string]$CabundlePath,
        [parameter(Mandatory=$true,Position=2)]
        [string]$CertPath
    )

    $cabundle = Get-Content $CabundlePath
    $cert = Get-Content $CertPath

    if ($cabundle -notcontains $cert) {
        Add-Content -Path $CabundlePath -Value $cert
        Write-Host "Certificate appended to $CabundlePath"
    } else {
        Write-Host "Certificate already present in $CabundlePath"
    }
}
