## Allows you to get a list of policies to determine which policies you want to use

# Built-in policies
# output file (.csv)
# Delimiter "|"

#specify file name below
$policyOutputFile = ""
Get-AzPolicyDefinition -BuiltIn | Select-Object {$_.Properties.DisplayName, '|', $_.Properties.Description, '|',  $_.ResourceID, '|',  $_.ResourceType} | export-csv -Path $policyOutputFile