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

## Build your required URL
$url = ""

## Invoke command
Invoke-RestMethod -Uri $url -Method GET -Headers $Headers