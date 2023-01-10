<#
    .SYNOPSIS
    Compares the folder structures of two folders and displays the differences.

    .DESCRIPTION
    This function compares the folder structures of two folders and displays the differences in a tree format.

    .PARAMETER Folder1
    The path of the first folder.

    .PARAMETER Folder2
    The path of the second folder.

    .EXAMPLE
    Compare-FolderStructures -Folder1 "C:\folder1" -Folder2 "C:\folder2"
#>
function Compare-FolderStructures {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$Folder1,

        [Parameter(Mandatory=$true)]
        [string]$Folder2
    )

    # Compare the folder structures and display the differences
    $differences = Compare-Object (Get-ChildItem $Folder1 -Recurse -Force | Select-Object FullName) (Get-ChildItem $Folder2 -Recurse -Force | Select-Object FullName) -Property FullName -IncludeEqual -ExcludeDifferent

    # Display the differences in a tree format
    $differences | ForEach-Object {
        $indent = "  " * ($_.FullName.Split("\") | Where-Object {$_} | Measure-Object).Count
        if ($_.SideIndicator -eq "<=") {
            Write-Host "$indent$($_.FullName) (Only in $Folder1)"
        }
        else {
            Write-Host "$indent$($_.FullName) (Only in $Folder2)"
        }
    }
}
