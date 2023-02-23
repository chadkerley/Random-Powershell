$foldersToDelete = @(
    "62",
    "69",
    "70"
)

$logFile = "C:\temp\EclipseCleanup.log"

$userProfiles = Get-ChildItem "C:\Users\" -Directory

$foldersDeleted = $false

foreach ($userProfile in $userProfiles) {
    $foldersToDelete | ForEach-Object {
        $folderPath = Join-Path $userProfile.FullName "\.studio\.org.eclipse.osgi\$_"
        if (Test-Path $folderPath) {
            try {
                Write-Host "Deleting $folderPath"
                Remove-Item -Path $folderPath -Recurse -Force -ErrorAction Stop
                Add-Content -Path $logFile -Value "Deleted folder $folderPath"
                $foldersDeleted = $true
            }
            catch {
                $errorMessage = "Error deleting $folderPath: $_"
                Write-Host $errorMessage
                Add-Content -Path $logFile -Value $errorMessage
            }
        }
    }
}

if ($foldersDeleted) {
    Add-Content -Path $logFile -Value "Eclipse cleanup completed successfully."
}
else {
    Add-Content -Path $logFile -Value "No folders to delete."
}
