param (
    [string]$cabundlePath = "ca-bundle.crt",
    [string]$certPath = "cert.crt"
)

$cabundle = Get-Content $cabundlePath
$cert = Get-Content $certPath

if ($cabundle -notcontains $cert) {
    Add-Content -Path $cabundlePath -Value $cert
    Write-Host "Certificate appended to $cabundlePath"
} else {
    Write-Host "Certificate already present in $cabundlePath"
}
