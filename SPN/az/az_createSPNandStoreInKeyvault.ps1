## powershell
Login-AzAccount
$subscriptionId = ''
Connect-AzAccount -Subscription $subscriptionId
$sub = Get-AzSubscription -SubscriptionId $subscriptionId
$spnName = ""
$sp1 = New-AzADServicePrincipal -DisplayName $spnName -Scope /subscriptions/$subscriptionId -Role Contributor
$clientsec = [System.Net.NetworkCredential]::new("", $sp1.Secret).Password

##read out variabes from $sp
$env:ARM_SUBSCRIPTION_ID = $subscriptionId
$env:ARM_CLIENT_ID = $sp1.ApplicationId.Guid
$env:ARM_CLIENT_SECRET = $clientsec
$env:ARM_TENANT_ID = $sub.TenantID

#Adding values to KeyVault
$keyvaultName = ""
$keyVaultLocation = ""
$spns = $sp1.ServicePrincipalNames[0] + "," +$sp1.ServicePrincipalNames[1]
$subIdSecret = Set-AzKeyVaultSecret -VaultName $keyvaultName -Name 'SubscriptionID' -SecretValue (ConvertTo-SecureString -String $subscriptionId -AsPlainText -Force)
$clientIdSecret = Set-AzKeyVaultSecret -VaultName $keyvaultName -Name 'ClientID' -SecretValue (ConvertTo-SecureString -String $sp1.ApplicationId.Guid -AsPlainText -Force)
$clientSecretSecret = Set-AzKeyVaultSecret -VaultName $keyvaultName -Name 'ClientSecret' -SecretValue(ConvertTo-SecureString -String  $clientsec -AsPlainText -Force)
$tenantIDSecret = Set-AzKeyVaultSecret -VaultName $keyvaultName -Name 'TenantID' -SecretValue(ConvertTo-SecureString -String  $sub.TenantId -AsPlainText -Force)
$spnSecret = Set-AzKeyVaultSecret -VaultName $keyvaultName -Name 'SPNs' -SecretValue(ConvertTo-SecureString -String $spns -AsPlainText -Force)

##Clean up time
##Get-AzADServicePrincipal -DisplayName $spnName | Remove-AzADServicePrincipal