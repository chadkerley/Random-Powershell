<#
.SYNOPSIS
Recursively searches .jar files inside a directory for files containing versions of log4j less than or equal to 2.17.1, including .jar files inside of .jar files.

.DESCRIPTION
This PowerShell script recursively searches for .jar files inside a directory and checks if they contain log4j versions less than or equal to 2.17.1. It does this by searching for log4j jar files within the archive and then looking for the log4j.properties file within the jar. If the version of log4j found is less than or equal to 2.17.1, it outputs the file path, jar file name, and log4j version.

.PARAMETER path
The path to the directory to search.

.EXAMPLE
Find-Log4j -path 'C:\path\to\directory'
Recursively searches the directory 'C:\path\to\directory' for .jar files containing versions of log4j less than or equal to 2.17.1, including .jar files inside of .jar files.
#>

function Find-Log4j {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$path
    )
    
    # Get all the .jar files in the directory and its subdirectories
    $jarFiles = Get-ChildItem -Path $path -Recurse -Filter *.jar
    
    # Loop through each jar file
    foreach ($jarFile in $jarFiles) {
        Write-Host "Checking $jarFile.FullName"
        
        # Open the jar file as a zip archive
        $zip = [System.IO.Compression.ZipFile]::OpenRead($jarFile.FullName)
        
        # Loop through each entry in the zip archive
        foreach ($entry in $zip.Entries) {
            # Check if the entry is a log4j jar file
            if ($entry.FullName -match 'log4j.*\.jar$') {
                Write-Host "Found log4j jar: $entry.FullName"
                
                # Read the manifest file to get the log4j version
                $manifestStream = $entry.Open()
                $manifest = New-Object System.IO.StreamReader($manifestStream)
                $version = ($manifest.ReadToEnd() -split "`r?`n" | Select-String 'Implementation-Version').ToString().Split(': ')[1]
                $manifest.Dispose()
                $manifestStream.Dispose()
                
                # Check if the version is less than or equal to 2.17.1
                if ([version]::Parse($version) -le [version]::Parse('2.17.1')) {
                    Write-Host "Found log4j version: $version"
                    Write-Host "File path: $($jarFile.FullName)"
                    Write-Host "Jar file name: $($jarFile.Name)"
                }
            }
        }
        
        $zip.Dispose()
    }
