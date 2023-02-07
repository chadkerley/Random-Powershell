# Kill GoToMeeting and GoTo Opener processes
Get-Process -Name "g2mstart", "g2mcomm", "g2mlauncher" | Stop-Process -Force

# GoToMeeting - uninstall system install
$installedApp = "GoToMeeting"
$keys = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall -ErrorAction SilentlyContinue
$items = $keys | Get-ItemProperty | Where-Object { $_.DisplayName -match $installedApp }
If ($items) {
    $uninstall = "$($items.UninstallString)" -replace "/I", "/X"
    Start-Process $uninstall -ArgumentList "/qn" -PassThru -Wait -ErrorAction SilentlyContinue
}

# GoToMeeting - uninstall user installs
Get-ChildItem -Path "C:\Users\*\AppData" G2MUninstall.exe -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
    Start-Process $_.FullName -ArgumentList "/uninstall /silent" -PassThru -Wait -ErrorAction SilentlyContinue
}

# GoToMeeting - delete user directories
Get-ChildItem "C:\Users\*\AppData" "GoToMeeting" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

# GoToMeeting - delete user desktop shortcuts
Get-ChildItem -Path "C:\Users\*\Desktop" GoToMeeting.lnk -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue

# GoToMeeting - delete user-installed registry keys
New-PSDrive -Name HKU -PSProvider Registry -Root Registry::HKEY_USERS
Get-ChildItem -Path HKU: | ForEach-Object {
    $uninstall = $_.Name + "\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $goToMeetingReg = Get-ChildItem -Path $uninstall -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "GoToMeeting" }
    If ($goToMeetingReg) {
        Remove-Item -Path $goToMeetingReg -Recurse -ErrorAction SilentlyContinue
    }
}
Remove-PSDrive -Name "HKU"

# GoTo Opener - delete registry install key because it can't be called by the system
$installedApp = "GoTo Opener"
$keys = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall -ErrorAction SilentlyContinue
$items = $keys | Get-ItemProperty | Where-Object { $_.DisplayName -eq $installedApp }
If ($items) {
    Remove-Item $items.PSPath -Recurse -Force -ErrorAction SilentlyContinue
}

# GoTo Opener - delete user directories
Get-ChildItem "C:\Users\*\AppData" "GoTo Opener" -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
    $Directory = $_.ToString()
    Remove-Item $Directory -Recurse -Force -ErrorAction SilentlyContinue
}

# GoTo Opener - delete user desktop shortcuts
Get-ChildItem -Path "C:\Users\*\Desktop" GoToOpener.lnk -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
    $ShortcutPath = $_.FullName
    Remove-Item $ShortcutPath -Force -ErrorAction SilentlyContinue
}

