function Remove-UWPApp
{
    param(
        [Parameter(Mandatory=$true)]
        [string]$appName,
        [string]$appVersion,
        [switch]$lt,
        [switch]$gt,
        [switch]$keeponly
    )

    # Check if both -lt and -gt switches are specified
    if ($lt -and $gt)
    {
        Write-Warning "It is not possible to remove all versions less than and greater than the specified version at the same time. Aborting execution."
        return
    }

    # Check if no version is specified and all versions should be removed
    if (-not $appVersion)
    {
        # Remove all versions of the app from the user profile
        Get-AppxPackage -Name $appName | Remove-AppxPackage

        # Remove all provisioned packages of the app
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -eq $appName | Remove-AppxProvisionedPackage -Online
    }
    else
    {
        # Check if the -lt switch is specified
        if ($lt)
        {
            # Remove all versions less than the specified version from the user profile
            Get-AppxPackage -Name $appName | Where-Object {$_.PackageVersion.ToString() -lt $appVersion} | Remove-AppxPackage

            # Remove all provisioned packages of the app that have a version less than the specified version
            Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq $appName -and $_.PackageVersion.ToString() -lt $appVersion} | Remove-AppxProvisionedPackage -Online
        }
        # Check if the -gt switch is specified
        elseif ($gt)
        {
            # Remove all versions greater than the specified version from the user profile
            Get-AppxPackage -Name $appName | Where-Object {$_.PackageVersion.ToString() -gt $appVersion} | Remove-AppxPackage

            # Remove all provisioned packages of the app that have a version greater than the specified version
            Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq $appName -and $_.PackageVersion.ToString() -gt $appVersion} | Remove-AppxProvisionedPackage -Online
        }
        # Check if the -keeponly switch is specified
        elseif ($keeponly)
        {
            # Remove all versions of the app besides the specified version from the user profile
            Get-AppxPackage -Name $appName | Where-Object {$_.PackageVersion.ToString() -ne $appVersion} | Remove-App
