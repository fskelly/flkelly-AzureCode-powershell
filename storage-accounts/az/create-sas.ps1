###########################################################
#                                                         #
#  Author : Fletcher Kelly                                #
#  Github : github.com/fskelly                            #
#  Purpose : Gte SAS URL for storage account              #
#  Built : 23-September-2022                              #
#  Last Tested : 23-September-2022                        #
#  Language : PowerShell                                  #
#                                                         #
###########################################################

##update as needed
$containerName = ""
$azureFileName = ""

$saContext = New-AzStorageContext -StorageAccountName $storageAccountName
$StartTime = Get-Date
$EndTime = $startTime.AddHours(24.0)
$sasToken = New-AzStorageBlobSASToken -Container $containerName -Blob $azureFileName -Permission rwd -StartTime $StartTime -ExpiryTime $EndTime -Context $saContext
$sasURL = "https://$($storageAccountName).blob.core.windows.net/$($containerName)$($sasToken)"