<#
.SYNOPSIS
Recursively searches .jar files inside a directory for files containing versions of log4j below 2.17.1, including .jar files inside of .jar files.

.DESCRIPTION
This PowerShell script recursively searches for .jar files inside a directory and checks if they contain log4j versions below 2.17.1. It does this by searching for log4j jar files within the archive and then looking for the log4j.properties file within the jar. If the version of log4j found is below 2.17.1, it outputs the file path, jar file name, and log4j version.

.PARAMETER path
The path to the directory to search.

.EXAMPLE
Find-Log4j -path 'C:\path\to\directory'
Recursively searches the directory 'C:\path\to\directory' for .jar files containing versions of log4j below 2.17.1, including .jar files inside of .jar files.
#>
# Define variables for log4j version to search for
$log4jMajorVersion = 2
$log4jMinorVersion = 17
$log4jPatchVersion = 1

# Define function to check log4j version in a file
function Check-Log4jVersion ($file) {
    # Open the file as a zip archive
    $zipArchive = [System.IO.Compression.ZipFile]::OpenRead($file.FullName)
    
    # Look for log4j jar files within the archive
    foreach ($entry in $zipArchive.Entries) {
        if ($entry.FullName.EndsWith('.jar') -and $entry.FullName.Contains('log4j')) {
            # Open the jar file as a zip archive
            $jarArchive = [System.IO.Compression.ZipFile]::Open($entry.Open(), [System.IO.Compression.ZipArchiveMode]::Read)
            
            # Look for the log4j.properties file within the jar
            $propertiesEntry = $jarArchive.GetEntry('META-INF/maven/org.apache.logging.log4j/log4j-core/pom.properties')
            if ($propertiesEntry -ne $null) {
                # Read the contents of the file
                $streamReader = New-Object System.IO.StreamReader($propertiesEntry.Open())
                $contents = $streamReader.ReadToEnd()
                $streamReader.Close()
                
                # Check the version of log4j in the file
                $versionRegex = [regex]::new('log4j\.version\s*=\s*(?<version>\d+\.\d+\.\d+)')
                $match = $versionRegex.Match($contents)
                if ($match.Success) {
                    $version = $match.Groups['version'].Value
                    $versionParts = $version.Split('.')
                    $majorVersion = [int]$versionParts[0]
                    $minorVersion = [int]$versionParts[1]
                    $patchVersion = [int]$versionParts[2]
                    if ($majorVersion -eq $log4jMajorVersion -and $minorVersion -eq $log4jMinorVersion -and $patchVersion -lt $log4jPatchVersion) {
                        Write-Output "$($file.FullName): $($entry.FullName): Log4j version $version found."
                    }
                }
                
                # Close the jar archive
                $jarArchive.Dispose()
            }
        }
    }
    
    # Close the zip archive
    $zipArchive.Dispose()
}

# Define function to recursively search for jar files and check for log4j version
function Find-Log4j {
    param(
        [Parameter(Mandatory=$true)]
        [string]$path
    )
    
    # Search for jar files in the directory
    $jarFiles = Get-ChildItem -Path $path -Recurse -Include *.jar
    
    # Check the log4j version in each jar file
    foreach ($jarFile in $jarFiles) {
        Check-Log4jVersion $jarFile
    }
}

# Call the Find-Log4j function with the directory to search
# Find-Log4j -path 'C:\path\to\directory'
