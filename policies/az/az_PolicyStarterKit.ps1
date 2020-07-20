## please insert your subscription id below
$subId = ""
Connect-AzAccount -Subscription $subId

## Set scope
#subscription scope
$subscription = Get-AzSubscription -subscriptionID $subId
$scope = $subscription.SubscriptionId
#resource group location
#$rgName = ""
#$rg = Get-AzResourceGroup -Name $rgName
#$scope = $rg.ResourceId

## allowed locations scope
## Please be aware of the scope here
# single or multiple regions can be used
# for example 
# $regions = "UAE" #OR
# $regions = "Europe","UAE"
$regions = ""
$policyAllowedLocation = @()
Foreach ($region in $regions)
{
    $region = "*" + $region + "*"
    $locations = Get-AzLocation | where-object {$_.displayname -like $region}
    Write-host $locations.location
    $policyAllowedLocation += $locations
}
$policy = Get-AzPolicyDefinition -BuiltIn | Where-Object {$_.Properties.DisplayName -eq 'Allowed locations'}
$allowedLocations = @{'listOfAllowedLocations'=($policyAllowedLocation.location)}
$policyName = [String]::Join(", ",$regions) + " Allowed Locations"
$policyAssignment = New-AzPolicyAssignment -Name $policyName -PolicyDefinition $policy -Scope $scope -PolicyParameterObject $allowedLocations

## allowed vm sizes
## Please be aware of the scope here
# single or multiple regions can be used
# for example 
# $regions = "UAE" #OR
# $regions = "Europe","UAE"
$regions = ""
$policyAllowedVMSkus = @()
Foreach ($allowedLocation in $policyAllowedLocation.location)
{
    # please type VM sku you want to whitelist
    # for example
    # $vmSku = "Standard_DS"
    $vmSku = ""
    $vmSku = "*" + $vmSku + "*"
    $vmSizes = Get-AzVMSize -Location $allowedLocation | Where-Object {$_.name -like $vmSku}
    $policyAllowedVmSizes += $vmSizes
    $policy = Get-AzPolicyDefinition -BuiltIn | Where-Object {$_.Properties.DisplayName -eq 'Allowed virtual machine size SKUs'}
    $allowedVmSizes = @{'listOfAllowedSKUs'=($vmSizes.Name)}
    $policyName = $allowedLocation + " Allowed VM SKUs"
    $policyName
    $policyAssignment = New-AzPolicyAssignment -Name $policyName -PolicyDefinition $policy -Scope $scope -PolicyParameterObject $allowedVmSizes
}

# Resource Group Location matches resource location - would suggest a Resource Group scope here.
## Please be aware of the scope here
## Set scope
#$rgName = ""
#$rg = Get-AzResourceGroup -Name $rgName
#$scope = $rg.ResourceId
$policy = Get-AzPolicyDefinition -BuiltIn | Where-Object {$_.Properties.DisplayName -eq 'Audit resource location matches resource group location'}
$policyName = "Resource Group locations matches resource location"
$policyAssignment = New-AzPolicyAssignment -Name $policyName -PolicyDefinition $policy -Scope $scope