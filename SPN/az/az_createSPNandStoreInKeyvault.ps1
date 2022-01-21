## powershell
Login-AzAccount
$subscriptions = Get-AzSubscription | Sort-Object SubscriptionName | Select-Object Name,SubscriptionId
[int]$subscriptionCount = $subscriptions.count
Write-Host "Found" $subscriptionCount "Subscriptions"
$i = 0
foreach ($subscription in $subscriptions)
{
  $subValue = $i
  Write-Host $subValue ":" $subscription.Name "("$subscription.SubscriptionId")"
  $i++
}
Do 
{
  [int]$subscriptionChoice = read-host -prompt "Select number & press enter"
} 
until ($subscriptionChoice -le $subscriptionCount)

Write-Host "You selected" $subscriptions[$subscriptionChoice].Name
Set-AzContext -SubscriptionId $subscriptions[$subscriptionChoice].SubscriptionId

$subscriptionId = $subscriptions[$subscriptionChoice].SubscriptionId

$tenantID = (Get-AzContext).Tenant.Id

$spnName = ""
$sp1 = New-AzADServicePrincipal -DisplayName $spnName -Scope /subscriptions/$subscriptionId -Role Contributor
$clientsec = [System.Net.NetworkCredential]::new("", $sp1.Secret).Password

##read out variabes from $sp
$env:ARM_SUBSCRIPTION_ID = $subscriptionId
$env:ARM_CLIENT_ID = $sp1.ApplicationId.Guid
$env:ARM_CLIENT_SECRET = $clientsec
$env:ARM_TENANT_ID = $tenantID

#Adding values to KeyVault
$keyvaultName = "flkellyKeyVault"
$keyVaultLocation = "North Europe"
$spns = $sp1.ServicePrincipalNames[0] + "," +$sp1.ServicePrincipalNames[1]
$subIdSecret = Set-AzKeyVaultSecret -VaultName $keyvaultName -Name 'SubscriptionID' -SecretValue (ConvertTo-SecureString -String $subscriptionId -AsPlainText -Force)
$clientIdSecret = Set-AzKeyVaultSecret -VaultName $keyvaultName -Name 'ClientID' -SecretValue (ConvertTo-SecureString -String $sp1.ApplicationId.Guid -AsPlainText -Force)
$clientSecretSecret = Set-AzKeyVaultSecret -VaultName $keyvaultName -Name 'ClientSecret' -SecretValue(ConvertTo-SecureString -String  $clientsec -AsPlainText -Force)
$tenantIDSecret = Set-AzKeyVaultSecret -VaultName $keyvaultName -Name 'TenantID' -SecretValue(ConvertTo-SecureString -String  $tenantID -AsPlainText -Force)
$spnSecret = Set-AzKeyVaultSecret -VaultName $keyvaultName -Name 'SPNs' -SecretValue(ConvertTo-SecureString -String $spns -AsPlainText -Force)

##Clean up time
##Get-AzADServicePrincipal -DisplayName $spnName | Remove-AzADServicePrincipal