## Build Token

## Attribution
## https://docs.microsoft.com/en-us/azure/active-directory/develop/v1-oauth2-client-creds-grant-flow#request-an-access-token
## Update Variables as needed
$TenantId = ""  # aka Directory ID. This value is Microsoft tenant ID
$ClientId = ""  # aka Application ID
$ClientSecret = ""  # aka key
$subscriptionID = ""
$Resource = "https://management.core.windows.net/"
$RequestAccessTokenUri = "https://login.microsoftonline.com/$TenantId/oauth2/token"

$Body = "grant_type=client_credentials&client_id=$ClientId&client_secret=$ClientSecret&resource=$Resource"
$Token = Invoke-RestMethod -Method Post -Uri $RequestAccessTokenUri -Body $Body -ContentType 'application/x-www-form-urlencoded'
# Build body with key-value pair
#$Body = @{'resource'= $Resource
#   'client_id' = $ClientId
#   'grant_type' = 'client_credentials'
#   'client_secret' = $ClientSecret
#}
Write-Host "Access Token JSON" -ForegroundColor Green
Write-Output $Token

$Headers = @{"Authorization" = "$($Token.token_type) "+ "$($Token.access_token)"}

## Variables
$subscriptionID = ""

## get all resource groups
$resourceGroups = (get-azresourcegroup)  | Select-Object -Property ResourceGroupName

#get the health of the whole resource group
# Add each health status to a hashtable before output a complete table with all resource groups and their resource health
$resourceGroupHealth = @{}
foreach ($resourceGroup in $resourceGroups) {
    
    #Set resource group name and use it in our url
    #$health = Invoke-RestMethod -Uri "https://management.azure.com/subscriptions/$subscriptionID/resourceGroups/$ResourceGroup/Providers/Microsoft.ResourceHealth/availabilityStatuses?api-version=2015-01-01" -Method GET -Headers $authHeader
    $rgName = $resourceGroup.ResourceGroupName
    $url = "https://management.azure.com/subscriptions/" + $subscriptionID + "/resourceGroups/" + $rgName + "/Providers/Microsoft.ResourceHealth/availabilityStatuses?api-version=2015-01-01"
    $url
    $health = Invoke-RestMethod -Uri $url -Method GET -Headers $Headers

    ## building PS Objects
    $currentHealth = @{}
    $currentHealth = @{
        [string]"$rgName" = [object]$health
    }
    $resourceGroupHealth += $currentHealth
}

## Explore overall object
$resourceGroupHealth

#Explore the results
foreach ($ResourceGroup in $ResourceGroups) {
    $rgName = $resourceGroup.ResourceGroupName
    $resourceGroupHealth.item($rgName).Value.Properties
}
