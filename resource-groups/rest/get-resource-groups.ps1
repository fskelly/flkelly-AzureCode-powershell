$subscriptionId = read-host "Enter your subscription ID"
$apiVersion = "2020-09-01"

$headers = @{
    "Authorization" = "Bearer $token"
}

$params = @{
    Uri = "https://management.azure.com/subscriptions/$subscriptionId/resourcegroups?api-version=$apiVersion"
    Method = "GET"
}

$queryResult = Invoke-RestMethod @params -Headers $headers 
$queryResult.value | select-object -Property name,location