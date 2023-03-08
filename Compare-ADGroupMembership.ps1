[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$User1,

    [Parameter(Mandatory = $true)]
    [string]$User2
)

# Get the two user accounts
$user1 = Get-ADUser -Identity $User1 -Properties memberof
$user2 = Get-ADUser -Identity $User2 -Properties memberof

# Get the group memberships for each user account
$groups1 = $user1.memberof | ForEach-Object { (Get-ADGroup $_).Name }
$groups2 = $user2.memberof | ForEach-Object { (Get-ADGroup $_).Name }

# Compare the group memberships and show the differences
$groupsOnlyIn1 = $groups1 | Where-Object { $_ -notin $groups2 }
$groupsOnlyIn2 = $groups2 | Where-Object { $_ -notin $groups1 }

if ($groupsOnlyIn1) {
    Write-Host "Groups only in $($user1.Name):" -ForegroundColor Yellow
    Write-Host $groupsOnlyIn1
}

if ($groupsOnlyIn2) {
    Write-Host "Groups only in $($user2.Name):" -ForegroundColor Yellow
    Write-Host $groupsOnlyIn2
}

if (-not $groupsOnlyIn1 -and -not $groupsOnlyIn2) {
    Write-Host "The group memberships for $($user1.Name) and $($user2.Name) are identical."
}
