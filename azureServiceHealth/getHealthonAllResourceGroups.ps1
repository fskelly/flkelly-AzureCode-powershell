## Build Token

## Attribution
## https://docs.microsoft.com/en-us/azure/active-directory/develop/v1-oauth2-client-creds-grant-flow#request-an-access-token
## Update Variables as needed
$tenantId = ""  # aka Directory ID (Tenant ID)
$clientId = ""  # aka Application ID
$clientSecret = ""  # aka key
$subscriptionID = ""
$resource = "https://management.core.windows.net/"
$requestAccessTokenUri = "https://login.microsoftonline.com/$tenantId/oauth2/token"

$body = "grant_type=client_credentials&client_id=$clientId&client_secret=$clientSecret&resource=$resource"
$token = Invoke-RestMethod -Method Post -Uri $requestAccessTokenUri -Body $body -ContentType 'application/x-www-form-urlencoded'
# Build body with key-value pair
#$Body = @{'resource'= $Resource
#   'client_id' = $ClientId
#   'grant_type' = 'client_credentials'
#   'client_secret' = $ClientSecret
#}
Write-Host "Access Token JSON" -ForegroundColor Green
Write-Output $token

$headers = @{"Authorization" = "$($token.token_type) "+ "$($token.access_token)"}

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
    $health = Invoke-RestMethod -Uri $url -Method GET -Headers $headers

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
foreach ($resourceGroup in $resourceGroups) {
    $rgName = $resourceGroup.ResourceGroupName
    $resourceGroupHealth.item($rgName).Value.Properties
}
