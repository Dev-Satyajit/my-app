param (
   $AppResourceGroupName,
   $AppName,
   $NetworkEnvionment
)

$secretName = "myapp-secret"

$keyvaultname = "ssappsprv-uw-kv-"+$NetworkEnvionment
$keyvaultRg = 'common-uw-rg-'+$NetworkEnvionment

$secretId = az keyvault secret show -n $secretName --vault-name $keyvaultname --query "id" -o tsv
$principalId = az functionapp identity show -n $AppName -g $AppResourceGroupName --query principalId -o tsv

az keyvault set-policy -n $keyvaultname -g $keyvaultRg --object-id $principalId --secret-permissions get
az functionapp config appsettings set -n $AppName -g $AppResourceGroupName --settings "test.secret=@Microsoft.KeyVault(SecretUri=$secretId)"