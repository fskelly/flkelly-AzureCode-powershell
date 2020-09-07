## To be used in conjunction with https://github.com/fskelly/flkelly-AzureCode-powershell/blob/WIP/keyVault/az/az_createKeyVault.ps1

$kvNameDiskEncryption = ""
$resourceGroupName = ""
$KeyVault = Get-AzKeyVault -VaultName $kvNameDiskEncryption -ResourceGroupName $resourceGroupName

## to do all vms
$vms = get-azvm
foreach ($vm in $vms)
{
    Write-host "Processing " $vm.name
    Set-AzVMDiskEncryptionExtension -ResourceGroupName $vm.ResourceGroupName -VMName $vm.Name -DiskEncryptionKeyVaultUrl $KeyVault.VaultUri -DiskEncryptionKeyVaultId $KeyVault.ResourceId
}

