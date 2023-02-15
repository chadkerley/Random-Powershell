## Nuke Chrome from orbit
$chrome = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "*Google Chrome*" }
$guid = $chrome.IdentifyingNumber
if ($chrome) {
    $process = Get-Process | Where-Object { $_.ProcessName -eq "chrome" }
    if ($process) {
        # try to close Chrome gracefully first
        $process.CloseMainWindow()
        # wait for Chrome to close or timeout after 60 seconds
        Start-Sleep -Seconds 60
        if (!$process.HasExited) {
            # kill Chrome after 60 seconds
            $process | Stop-Process -Force
            Start-Sleep -Seconds 10
        }
    }
    # uninstall Chrome using MSI and remove Chrome directories
    Start-Process -FilePath "msiexec" -ArgumentList "/x", "$guid", "/qn" -Wait
    Remove-Item -Path "$env:ProgramFiles(x86)\Google\Chrome" -Recurse -Force
    Remove-Item -Path "$env:ProgramFiles\Google\Chrome" -Recurse -Force
}
