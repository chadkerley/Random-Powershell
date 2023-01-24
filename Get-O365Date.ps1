$machines = Get-Content "C:\machines.txt"

foreach ($machine in $machines) {
    $office = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*Office 365*"}
    if ($office) {
        $installDate = $office.InstallDate
        $formattedDate = (Get-Date $installDate).ToString()
        Write-Host "Office 365 was installed on $machine on $formattedDate"
    } else {
        Write-Host "Office 365 not found on $machine"
    }
}
