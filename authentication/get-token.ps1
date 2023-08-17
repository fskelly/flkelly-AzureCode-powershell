# Prompt the user for their Azure tenant ID and client ID

$tenantId = Read-Host "Enter your Azure tenant ID"
$clientID = Read-Host "Enter your Azure client ID"
$clientSecret = Read-host "enter your client secret" -AsSecureString

$normalString = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($clientSecret))

$params = @{
    Uri = "https://login.microsoftonline.com/$tenantId/oauth2/token"
    Method = "POST"
    Body = @{
        grant_type = "client_credentials"
        scope = "https://management.azure.com"
        client_id = $clientID
        client_secret = $normalString
    }
}

$authResult = Invoke-RestMethod @params

# Output the access token
$token = $authResult.access_token
