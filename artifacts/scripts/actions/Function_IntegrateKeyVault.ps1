param (
   $AppResourceGroupName,
   $AppName,
   $Envionment,
   $NetworkEnvionment
)

$secretName = $Envionment+"-app-registration-key"

$keyvaultname = "ssappspub-ci-kv-"+$NetworkEnvionment
$keyvaultRg = 'common-ci-rg-'+$NetworkEnvionment

$principalId = az functionapp identity show -n $AppName -g $AppResourceGroupName --query principalId -o tsv

az keyvault set-policy -n $keyvaultname -g $keyvaultRg --object-id $principalId --secret-permissions get
az functionapp config appsettings set -n $AppName -g $AppResourceGroupName --settings "keyVault_clientKey=@Microsoft.KeyVault(VaultName=$keyvaultname;SecretName=$secretName)"