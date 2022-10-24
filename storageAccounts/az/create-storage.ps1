###########################################################
#                                                         #
#  Author : Fletcher Kelly                                #
#  Github : github.com/fskelly                            #
#  Purpose : Deploy storage account                       #
#  Built : 23-September-2022                              #
#  Last Tested : 23-September-2022                        #
#  Language : PowerShell                                  #
#                                                         #
###########################################################


##update as needed
$resourceGroupLocation = ""
$storageRgName = ""

## Storage account variables
$guid = New-Guid
$storageAccountName = "sa"
$storageAccountNameSuffix = $guid.ToString().Split("-")[0]
$storageAccountName = (($storageAccountName.replace("-",""))+$storageAccountNameSuffix )

## Define tags to be used if needed
## tags can be modified to suit your needs, another example below.
#$tags = @{"Environment"="Development";"Owner"="Fletcher Kelly";"CostCenter"="123456"}
$tags = @{"deploymentMethod"="PowerShell"}

## create storage account
New-AzStorageAccount -ResourceGroupName $storageRgName -Name $storageAccountName -Location $resourceGroupLocation -SkuName Standard_LRS -Kind StorageV2 -EnableHttpsTrafficOnly $true -Tags $tags

## container variables
$containerName = "conatiner1"
New-AzStorageContainer -name $containerName -Context (Get-AzStorageAccount -ResourceGroupName $storageRgName -Name $storageAccountName).Context

## copy file to azure storage container
$localFilePath = ""
$azureFileName = $localFilePath.Split('\')[$localFilePath.Split('\').count-1]
Get-AzStorageAccount -Name $storageAccountName -ResourceGroupName $storageRgName | Get-AzStorageContainer -Name $containerName | Set-AzStorageBlobContent -File $localFilePath -Blob $azureFileName