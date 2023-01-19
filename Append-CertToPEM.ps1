function Append-CertToPEM {
    <#
    .SYNOPSIS
        Appends a certificate to a PEM file, after checking for duplicates and validating the format of the PEM file
    .DESCRIPTION
        This function will append a certificate to a PEM file, after checking for duplicates and validating the format of the PEM file.
        It will also make a backup of the original PEM file.
    .PARAMETER PemPath
        The path of the PEM file
    .PARAMETER CrtPath
        The path of the certificate file
    .EXAMPLE
        Append-Certificate -PemPath "c:\path\to\file.pem" -CrtPath "c:\path\to\cert.crt"
    #>
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true,Position=1)]
        [string]$PemPath,
        [parameter(Mandatory=$true,Position=2)]
        [string]$CrtPath
    )

    # Check for duplicates
    $pem = Get-Content $PemPath
    $crt = Get-Content $CrtPath
    $duplicate = Compare-Object -ReferenceObject $crt -DifferenceObject $pem -IncludeEqual

    if ($duplicate) {
        Write-Host "Certificate already present in $PemPath"
        return
    }

    # Validate format of PEM file
    $pemFormat = Get-Content $PemPath -Raw
    if (!($pemFormat -match "-----BEGIN.*-----")) {
        Write-Host "Invalid PEM format in $PemPath"
        return
    }

    # Make a backup of the original file
    $backup = "$PemPath.bak"
    Copy-Item -Path $PemPath -Destination $backup

    # Append the .crt file to the end of the .pem file
    Add-Content -Path $PemPath -Value $crt
    Write-Host "Certificate appended to $PemPath"
}
