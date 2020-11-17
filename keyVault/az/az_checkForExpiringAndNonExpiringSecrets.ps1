## https://docs.microsoft.com/en-us/azure/key-vault/general/howto-logging

$vaultName = ""
$kvRG = ""
$kv = Get-AzKeyVault -ResourceGroupName $kvRG -VaultName $vaultName
$secrets = Get-AzKeyVaultSecret -VaultName $kv.VaultName

$nonExpiringSecrets = $secrets | Where-Object {$_.Expires -eq $null}
$expiringSecrets = $secrets | Where-Object {$_.Expires -ne $null}

$daysToCheck = 90
$expireDate = (Get-Date).AddDays($daysToCheck)

foreach ($expiringSecret in $expiringSecrets)
{
    if ($expiringSecret.Expires -lt $expireDate)
    {
        Write-Host ($expiringSecret).name "is in the expiry window of $daysToCheck days"
    }
}
foreach ($nonExpiringSecret in $nonExpiringSecrets)
{
    Write-host ($nonExpiringSecret).name " is set to NEVER expire"
}