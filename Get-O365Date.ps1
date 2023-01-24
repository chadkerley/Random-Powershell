$machines = Get-Content "C:\machines.txt"

foreach ($machine in $machines) {
    # Enable remote PowerShell on the machine
    Invoke-Command -ComputerName $machine -ScriptBlock { Enable-PSRemoting -Force }
    # Open the remote registry key
    $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $machine)
    $key = $reg.OpenSubKey("SOFTWARE\\Microsoft\\SMS\\Mobile Client\\Software Distribution\\Execution History\\System\\ABC00416")
    if ($key) {
        $installDate = $key.GetValue("Start Time")
        $formattedDate = (Get-Date $installDate).ToString()
        Write-Host "Office 365 was installed on $machine on $formattedDate"
    } else {
        Write-Host "Office 365 not found on $machine"
    }
}
