$resourceGroupName = ""
$location = ""

if ([string]::IsNullOrEmpty($resourceGroupName) -or [string]::IsNullOrEmpty($location)) {
    Write-Host "Resource group name or location is empty. Please check your inputs."
    return
}

try {
    New-AzResourceGroup -Name $resourceGroupName -Location $location
} catch {
    Write-Host "Failed to create resource group. Error: $_"
    return
}

$kvNameDiskEncryption = ""
$kvNameSecrets = ""

if ([string]::IsNullOrEmpty($kvNameDiskEncryption) -or [string]::IsNullOrEmpty($kvNameSecrets)) {
    Write-Host "Key vault names are empty. Please check your inputs."
    return
}

try {
    New-AzKeyVault -Name $kvNameDiskEncryption -ResourceGroupName $resourceGroupName -Location $location -EnabledForDiskEncryption
} catch {
    Write-Host "Failed to create key vault for disk encryption. Error: $_"
    return
}

try {
    New-AzKeyVault -Name $kvNameSecrets -ResourceGroupName $resourceGroupName -Location $location
} catch {
    Write-Host "Failed to create key vault for secrets. Error: $_"
    return
}