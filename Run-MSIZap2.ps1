[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ProductName,

    [Parameter(Mandatory = $true)]
    [string]$Computer
)

$LogFile = "Remove-$ProductName.log"
$LogFilePath = "\\$Computer\c$\temp\$LogFile"

Write-Output "Starting removal of $ProductName from $Computer..." | Tee-Object -FilePath $LogFilePath -Append

try {
    $Product32 = Get-WmiObject -Class Win32_Product -ComputerName $Computer -Filter "Name='$ProductName'" | Select-Object -First 1
    if ($Product32) {
        $GUID = $Product32.IdentifyingNumber
        Write-Output "Found 32-bit version of $ProductName with GUID ${GUID}" | Tee-Object -FilePath $LogFilePath -Append
        $Status = Start-Process -FilePath "C:\tools\pstools\psexec.exe" -ArgumentList "\\$Computer C:\Windows\System32\MsiZap.exe tw! ${GUID}" -Wait -Passthru
        if ($Status.ExitCode -eq 0) {
            Write-Output "Removed 32-bit version of $ProductName with GUID ${GUID} from $Computer" | Tee-Object -FilePath $LogFilePath -Append
        } else {
            Write-Output "Error removing 32-bit version of $ProductName with GUID ${GUID} from $Computer: $Status" | Tee-Object -FilePath $LogFilePath -Append
        }
    } else {
        Write-Output "No 32-bit version of $ProductName found on $Computer" | Tee-Object -FilePath $LogFilePath -Append
    }

    $Product64 = Get-WmiObject -Class Win32_Product -ComputerName $Computer -Filter "Name='$ProductName'" -Namespace "root\CIMV2" | Select-Object -First 1
    if ($Product64) {
        $GUID = $Product64.IdentifyingNumber
        Write-Output "Found 64-bit version of $ProductName with GUID ${GUID}" | Tee-Object -FilePath $LogFilePath -Append
        $Status = Start-Process -FilePath "C:\tools\pstools\psexec.exe" -ArgumentList "\\$Computer C:\Windows\SysWOW64\MsiZap.exe tw! ${GUID}" -Wait -Passthru
        if ($Status.ExitCode -eq 0) {
            Write-Output "Removed 64-bit version of $ProductName with GUID ${GUID} from $Computer" | Tee-Object -FilePath $LogFilePath -Append
        } else {
            Write-Output "Error removing 64-bit version of $ProductName with GUID ${GUID} from $Computer: $Status" | Tee-Object -FilePath $LogFilePath -Append
        }
    } else {
        Write-Output "No 64-bit version of $ProductName found on $Computer" | Tee-Object -FilePath $LogFilePath -Append
    }
} catch {
    Write-Output "An error occurred while removing $ProductName from $Computer: $_" | Tee-Object -FilePath $LogFilePath -Append
}

Write-Output "Removal of $ProductName from $Computer completed" | Tee-Object -FilePath $LogFilePath -Append
