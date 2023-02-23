$foldersToDelete = @(
    "62",
    "69",
    "70"
)

$userProfiles = Get-ChildItem "C:\Users\" -Directory

foreach ($userProfile in $userProfiles) {
    $foldersToDelete | ForEach-Object {
        $folderPath = Join-Path $userProfile.FullName "\.studio\.org.eclipse.osgi\$_"
        if (Test-Path $folderPath) {
            try {
                Write-Host "Deleting $folderPath"
                Remove-Item -Path $folderPath -Recurse -Force -ErrorAction Stop
            }
            catch {
                Write-Host "Error deleting $folderPath: $_"
            }
        }
    }
}
