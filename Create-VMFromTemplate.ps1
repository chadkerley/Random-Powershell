# Connect to vSphere server using PowerCLI
Connect-VIServer <vSphere server>

# Get datastore with the most free space
$datastore = Get-Datastore | Sort-Object FreeSpaceGB -Descending | Select-Object -First 1

# Specify the name of the template to use
$templateName = "MyTemplate"

# Read a list of hostnames from a text file
$hostnamesFile = "<path to file>"
$hostnames = Get-Content $hostnamesFile

# Loop through each hostname in the list and create a VM
foreach ($computerName in $hostnames) {
    # Create a new VM configuration object
    $vmConfig = New-VM -Name $computerName -Template $templateName -Datastore $datastore.Name

    # Start the VM
    $vmConfig
}

# Disconnect from vSphere server
Disconnect-VIServer -Confirm:$false
