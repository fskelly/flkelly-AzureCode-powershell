Login-AzAccount
$subscriptions = Get-AzSubscription | Sort-Object SubscriptionName | Select-Object Name,SubscriptionId
[int]$subscriptionCount = $subscriptions.count
Write-output "Found" $subscriptionCount "Subscriptions"

# Check if there are any subscriptions found
if ($subscriptionCount -eq 0) {
  Write-Output "No subscriptions found. Please ensure you have access to at least one Azure subscription."
  return
}

$i = 0
foreach ($subscription in $subscriptions | Sort-Object -Property Name )
{
  $subValue = $i
  $subText = [string]$subValue + " : " + $subscription.Name + " ( " + $subscription.SubscriptionId + " ) "
  Write-output $subText
  $i++
}
Do 
{
  [int]$subscriptionChoice = read-host -prompt "Select number & press enter"
} 
until ($subscriptionChoice -le $subscriptionCount)

$selectedSub = "You selected " + $subscriptions[$subscriptionChoice].Name
Write-output $selectedSub
Set-AzContext -SubscriptionId $subscriptions[$subscriptionChoice].SubscriptionId
