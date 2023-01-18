$azSubscriptionID = ""
Login-AzAccount
Set-AzContext -Subscription $azSubscriptionID

## Get certs
$openSSLFilePath = "C:\Program Files\OpenSSL-Win64\bin\openssl.exe"
## Update remoteComputers with your LDAPS servers
$remoteComputers= "",""
$port = "636"
## Update exportFolder with your desired location
$exportFolder = "c:\temp\"

foreach ($computer in $remoteComputers)
{
    $output =  echo "1" | & $openSSLFilePath "s_client" "-connect" "$computer`:$port" "-showcerts" | out-string
    $Matches = $null
    $cn = $output -match "0 s\:CN = (?<cn>.*?)\r\n"
    $cn = $Matches.cn
    $Matches = $null
    $certs = select-string -inputobject $output -pattern "(?s)(?<cert>-----BEGIN CERTIFICATE-----.*?-----END CERTIFICATE-----)" -allmatches
    $cert = $certs.matches[0]
    $exportPath = $exportFolder+($computer.split(".")[0])+".cer"
    $cert.Value | Out-File $exportPath -Encoding ascii
}

## Do you have Azure Module installed?
if (Get-Module -ListAvailable -Name Az.Storage)
{ write-output "Module exists"
} else {
    write-output "Module does not exist"
    write-output "Installing Module"
    Install-Module -Name Az.Storage -Scope CurrentUser -Force -AllowClobber
}

## create storage account
## Update variables to suit your needs
$technology = ""
$resourceGroupLocation = ""
$storageRgName = "$technology-$resourceGroupLocation-operational_rg"
## Storage account variables
$guid = New-Guid
$storageAccountName = "avsgwcsa"
$storageAccountNameSuffix = $guid.ToString().Split("-")[0]
$storageAccountName = (($storageAccountName.replace("-",""))+$storageAccountNameSuffix )
## Define tags to be used if needed
## tags can be modified to suit your needs, another example below.
#$tags = @{"Environment"="Development";"Owner"="Fletcher Kelly";"CostCenter"="123456"}
$tags = @{"deploymentMethod"="PowerShell"; "Technology"="AVS"}
## create storage account
$saCheck = Get-AzStorageAccount -ResourceGroupName $storageRgName -Name $storageAccountName -ErrorAction SilentlyContinue
if ($null -eq $saCheck)
{
    New-AzStorageAccount -ResourceGroupName $storageRgName -Name $storageAccountName -Location $resourceGroupLocation -SkuName Standard_LRS -Kind StorageV2 -EnableHttpsTrafficOnly $true -Tags $tags
    Write-Output "Storage account created: $storageAccountName"
} else {
    write-output "Storage Account already exists"
}

## create container
## Update variables to suit your needs
$containerName = "ldaps"
$containerCheck = Get-AzStorageContainer -name $containerName -Context (Get-AzStorageAccount -ResourceGroupName $storageRgName -Name $storageAccountName).Context -ErrorAction SilentlyContinue
if ($null -eq $containerCheck)
{
    New-AzStorageContainer -name $containerName -Context (Get-AzStorageAccount -ResourceGroupName $storageRgName -Name $storageAccountName).Context
    Write-Output "Storage container created: $containerName"
} else {
    write-output "Container already exists"
}

## upload certs to container
$certs = Get-ChildItem -Path $exportFolder -Filter *.cer
$storageContext = (Get-AzStorageAccount -Name $storageAccountName -ResourceGroupName $storageRgName).Context
foreach ($item in $certs)
{
    $localFilePath = $item.FullName
    $azureFileName = $localFilePath.Split('\')[$localFilePath.Split('\').count-1]
    Get-AzStorageAccount -Name $storageAccountName -ResourceGroupName $storageRgName | Get-AzStorageContainer -Name $containerName | Set-AzStorageBlobContent -File $localFilePath -Blob $azureFileName
}

## create SAS token
## Update variables to suit your needs
$containerName = "ldaps"
$blobs = Get-AzStorageBlob -Container $containerName -Context $storageContext | Where-Object {$_.name -match ".cer"}
foreach ($blob in $blobs)
{
    $StartTime = Get-Date
    $EndTime = $startTime.AddHours(24.0)
    $sasToken = New-AzStorageBlobSASToken -Container $containerName -Blob $blob.name -Permission rwd -StartTime $StartTime -ExpiryTime $EndTime -Context $storageContext -FullUri
    #$sasToken
    write-host "SASToken created: $sasToken"
}

## Reference for az vmware run example - https://github.com/khensler/VMware_Scripts/blob/main/AVS/setVMStoragePolicy.ps1