<#
    .SYNOPSIS
    Retrieves user information from Active Directory for a list of users.

    .DESCRIPTION
    Retrieves the display name, user principal name and email of a list of users from Active Directory. The list of users can be provided as a .txt file, one userPrincipalName per line. The results are saved to a .csv file in the specified output path.

    .PARAMETER UserListFile
    The path of the .txt file containing the list of users.

    .PARAMETER OutputPath
    The path of the directory where the output .csv file will be saved. Default is C:\temp\

    .EXAMPLE
    PS C:\> Get-UserInfo -UserListFile C:\path\to\users.txt -OutputPath "C:\myoutput\"

#>

function Get-UserInfo {
    [CmdletBinding(DefaultParameterSetName='ByName', SupportsShouldProcess=$true, ConfirmImpact='Medium')]
    param(
        [string]$UserListFile,
        [string]$OutputPath = "C:\temp\"
    )
    begin {
        Write-Verbose "Starting the function"
    }
    process {
        Import-Module ActiveDirectory
        $users = Get-Content $UserListFile
        # Create an empty array to store the results
        $results = @()
        foreach ($user in $users) {
            try {
                $user = Get-ADUser -Identity $user -Properties mail, displayName
                $result = [PSCustomObject]@{
                    'Display Name' = $user.displayName
                    'User Name' = $user.userPrincipalName
                    'Email' = $user.mail
                }
                $results += $result
                Write-Verbose "Processing $user"
            }
            catch {
                Write-Error "Error: $user is not a valid Active Directory user."
            }
        }
        # Create the timestamp string
        $timestamp = Get-Date -Format yyyy-MM-dd-HH-mm
        # Create the output file name
        $outputFile = "$OutputPath\UserInfo-$timestamp.csv"
        # Export the results to a CSV file
        $results | Export-Csv -Path $outputFile -NoTypeInformation
    }
    end {
        Write-Verbose "Finished the function"
    }
}
