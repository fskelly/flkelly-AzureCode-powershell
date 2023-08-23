$ErrorActionPreference = "SilentlyContinue"

$tenantId = Read-Host "Enter your Azure tenant ID"
$clientID = Read-Host "Enter your Azure client ID"
$clientSecret = Read-host "enter your client secret" -AsSecureString

$normalString = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($clientSecret))

$params = @{
    Uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
    Method = "POST"
    Body = @{
        grant_type = "client_credentials"
        scope = "https://management.azure.com/.default"
        client_id = $clientID
        client_secret = $normalString
    }
}

$authResult = Invoke-RestMethod @params

if ([string]::IsNullOrEmpty($token)) {
    Write-output "Token is empty or null"
    Write-Output "Error: $Error"
} else {
    # Output the access token
    $token = $authResult.access_token
    Write-Output "Token is $token"
}

