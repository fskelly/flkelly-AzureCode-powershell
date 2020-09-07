$resourceGroupName = ""
$location = ""

new-azresourceGroup -name $resourceGroupName -location $location

$kvNameDiskEncryption = ""
new-azkeyvault -name $kvNameDiskEncryption -resourcegroupname $resourceGroupName -location $location -EnabledForDiskEncryption

$kvNameSecrets = ""
new-azkeyvault -name $kvNameSecrets -resourcegroupname $resourceGroupName -location $location