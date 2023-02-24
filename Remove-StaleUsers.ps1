<#
.SYNOPSIS
Removes inactive user profiles from a Windows 10 machine.

.DESCRIPTION
The Remove-StaleUsers cmdlet removes user profiles from a Windows 10 machine that have been inactive for a specified number of days. By default, the cmdlet removes profiles that have not been logged into for 365 days.

.PARAMETER Days
The number of days a user profile must be inactive before it's removed. Default is 365.

.PARAMETER AdminOnly
If specified, only user profiles with usernames ending in the letter 'A' will be removed.

.EXAMPLE
PS C:\> Remove-StaleUsers -Days 90
This example removes user profiles that have not been logged into for 90 days.

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [int]$Days = 365,

    [Parameter(Mandatory = $false)]
    [switch]$AdminOnly
)

# Automatically enable AdminOnly mode if $Days is less than 90
if ($Days -lt 90) {
    Write-Host "Auto-enabling AdminOnly mode because Days is less than 90"
    $AdminOnly = $true
}

# Configure log file path and format
$logFile = 'C:\Windows\Temp\Remove-StaleUsers.log'
$logFormat = '[$(Get-Date)] $($MyInvocation.MyCommand.Name): {0}'

# Create or append to the log file
New-Item -ItemType File -Path $logFile -Force | Out-Null

$date = (Get-Date).AddDays(-$Days)

# Get list of user profiles on the machine
$profiles = Get-ChildItem -Path 'C:\Users' -Directory | Select-Object -ExpandProperty Name

# Loop through each user profile and determine if it should be removed
foreach ($profile in $profiles) {
    $username = $profile

    # Check if the user is inactive
    $lastWriteTime = (Get-Item -Path "C:\Users\$username").LastWriteTime
    if ($lastWriteTime -lt $date) {

        # Check if the user is an admin (if -AdminOnly switch is used)
        if ($AdminOnly) {
            if ($username[-1] -ne 'A') {
                Write-Host "Skipping $username because it does not end with 'A'"
                Add-Content -Path $logFile -Value ($logFormat -f "Skipping $username because it does not end with 'A'")
                continue
            }
        }

        # Remove the user profile
        Write-Host "Removing profile for $username"
        Add-Content -Path $logFile -Value ($logFormat -f "Removing profile for $username")
        Remove-Item -Path "C:\Users\$username" -Recurse -Force -WhatIf | Out-Null
    }
}
