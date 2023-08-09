## function to select a subscription and connect to it
function Select-SubscriptionsAndConnectTo {
    Login-AzAccount
    $subscriptions = Get-AzSubscription | Select-Object Name,SubscriptionId | Sort-Object Name 
    [int]$subscriptionCount = $subscriptions.count
    Write-output "Found" $subscriptionCount "Subscriptions"
    $i = 0
    foreach ($subscription in $subscriptions)
    {
        $subValue = $i
        $subText = [string]$subValue + " : " + $subscription.Name + " ( " + $subscription.SubscriptionId + " ) "
        Write-output $subText
        $i++
    }
    Do 
    {
        [int]$subscriptionChoice = read-host -prompt "Select number & press enter"
    } 
    until ($subscriptionChoice -le $subscriptionCount)

    $selectedSub = "You selected " + $subscriptions[$subscriptionChoice].Name
    Write-output $selectedSub
    Set-AzContext -SubscriptionId $subscriptions[$subscriptionChoice].SubscriptionId
}

Select-SubscriptionsAndConnectTo

## getting all vms in a subscription
$vms = Get-AzVM
$vms | Select-Object Name,ResourceGroupName,Location,@{l='VMSize';e={$_.HardwareProfile.VmSize}}| Sort-Object Name | Format-Table -AutoSize
## reading in virtual machines
$selectedVmName = read-host "Which VM would you like to check for better pricing?"
$selectedRGName = $vms | Where-Object { $_.Name -eq $selectedVmName } | Select-Object ResourceGroupName

## checking for duplicate names in multiple resource groups
if ($selectedRGName.count -gt 1)
{
    $rgCount = $selectedRGName.count
    Write-Output "Found multiple VMs with the same name in different resource groups"
    $rgNames = $selectedRGName | Select-Object ResourceGroupName
    #write-output $rgNames.resourcegroupname
    $i = 0
    foreach ($rgName in $rgNames)
    {
        $rgValue = $i
        $rgText = [string]$rgValue + " : " + $rgName.ResourceGroupName
        Write-output $rgText
        $i++
    }
    Do 
    {
        [int]$rgChoice = read-host -prompt "Select number & press enter"
    } 
    until ($rgChoice -le $rgCount-1)

    $selectedRGText = "You selected " + $selectedRGName[$rgChoice].ResourceGroupName
    Write-output $selectedRGText
    $selectedRG = $selectedRGName[$rgChoice].ResourceGroupName

    ## selcting the vm from the selected resource group
    $azureVm = get-azvm -ResourceGroupName $selectedRG -Name $selectedVmName
} else {
    ## selcting the vm from the selected resource group
    $azureVm = get-azvm -ResourceGroupName $selectedRGName.ResourceGroupName -Name $selectedVmName
}

## building variables for api call
$azureVMSKU = $azureVm.HardwareProfile.VmSize
$azureVmLocation = $azureVm.Location

## api variables
$apiUrl = "https://prices.azure.com/api/retail/prices?"
$armSkuName = $azureVMSKU

## get base information around pricing

$baseFilter = "armSkuName eq '$armSkuName' and priceType eq 'Consumption' and armRegionName eq '$azureVmLocation'"
$baseUrl = $apiUrl + "`$filter=$baseFilter"
Write-Output "Current Url is $baseUrl"
$baseJsonData = Invoke-RestMethod -Uri $baseUrl -Method Get
## selecting most expensive price
$baseVMPrice = ($baseJsonData.Items  | Where-Object { $_.skuName -notlike "*Spot*" -and $_.skuName -notlike "*Low Priority*" } | Sort-Object unitPrice -Descending | Select-Object -Last 1).unitPrice

## formating for results
$baseVMPrice = "{0:N4}" -f $baseVMPrice
Write-Output "Base price is $baseVMPrice"

## get all pricing data for the selected vm
$filter = "armSkuName eq '$armSkuName' and priceType eq 'Consumption'"
$allItems = @()

# Run Query
$url = $apiUrl + "`$filter=$filter"
Write-Output "Current Url is $url"
$currentJsonData = Invoke-RestMethod -Uri $url -Method Get
$allItems += $currentJsonData.Items

# pagination
$NextPage = $currentJsonData.NextPageLink
while ($NextPage) {
    Write-Verbose "Current Url is $NextPage"
    $currentJsonData = Invoke-RestMethod -Uri $NextPage -Method Get
    $allItems += $currentJsonData.Items
    $NextPage = $currentJsonData.NextPageLink
}

# filter out spot and low priority item from array
$filteredItems = $allItems | Select-Object skuName, meterName, unitOfMeasure, @{l='unitPrice';e={"{0:N4}" -f $_.unitPrice}}, armRegionName | Where-Object { $_.skuName -notlike "*Spot*" -and $_.skuName -notlike "*Low Priority*" }
Write-Output "Total items: $($filteredItems.Count)"
#$filteredItems
$filteredItems | Sort-Object -Property unitPrice | Format-Table -AutoSize
$cheaperOptions = $filteredItems | Where-Object -Property unitPrice -lt $baseVMPrice | Sort-Object -Property unitPrice
Write-Output "Cheaper than $baseVMPrice options: $($cheaperOptions.Count)"
$cheaperOptions | Format-Table -Property skuName, meterName, unitOfMeasure, @{l='unitPrice';e={"{0:N4}" -f $_.unitPrice}}, armRegionName -AutoSize

## how to check against specific regions
$regionCheck = read-host "Would you like to check against specific regions? (y/n)"
while("y","n" -notcontains $regionCheck) {
    $regionCheck = read-host "Would you like to check against specific regions? (y/n)"
}
if ($regionCheck -eq "y")
{
    $specificRegions = read-host "please enter region names seperated by comma"
    $specificRegions = $specificRegions.split(",")

    $regionItems = @()
    $regionQueryBaseUrlFilter = "armSkuName eq '$armSkuName' and priceType eq 'Consumption' "
    
    foreach ($item in $specificRegions)
    {
        $item
        $regionQueryBaseUrlFilter = "armSkuName eq '$armSkuName' and priceType eq 'Consumption' "
        $regionQueryBaseUrlFilter = $regionQueryBaseUrlFilter + "and armRegionName eq '$item' "
        $regionQueryBaseUrlFilter
        $regionQueryUrl = $apiUrl + "`$filter=$regionQueryBaseUrlFilter"
        $otherRegionJsonData = Invoke-RestMethod -Uri $regionQueryUrl -Method Get
        $regionItems += $otherRegionJsonData.Items
        $NextPage = $otherRegionJsonData.NextPageLink
        while ($NextPage) {
            Write-Output "Current Url is $NextPage"
            $otherRegionJsonData = Invoke-RestMethod -Uri $NextPage -Method Get
            $regionItems += $otherRegionJsonData.Items
            $NextPage = $otherRegionJsonData.NextPageLink
        }
    }
    
    Write-Output "Output below"
    $regionItems | Where-Object { $_.skuName -notlike "*Spot*" -and $_.skuName -notlike "*Low Priority*" } | Format-Table -Property skuName, meterName, unitOfMeasure, @{l='unitPrice';e={"{0:N4}" -f $_.unitPrice}}, armRegionName -AutoSize
    }

## included to checking and troubleshooting - reading out comma seperated list
