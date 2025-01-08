param (
   $AppResourceGroupName,
   $AppName,
   $Envionment,
   $NetworkEnvionment
)

$secretName = $Envionment+"-app-registration-key"

$keyvaultname = "ssappspub-ci-kv-"+$NetworkEnvionment
$keyvaultRg = 'common-ci-rg-'+$NetworkEnvionment

$ipAddress = (Invoke-WebRequest ifconfig.me/ip).Content.Trim()
az keyvault network-rule add -n $keyvaultname -g $keyvaultRg --ip-address $ipAddress
$secretId = az keyvault secret show -n $secretName --vault-name $keyvaultname --query "id" -o tsv

$principalId = az functionapp identity show -n $AppName -g $AppResourceGroupName --query principalId -o tsv
az keyvault set-policy -n $keyvaultname -g $keyvaultRg --object-id $principalId --secret-permissions get
az functionapp config appsettings set -n $AppName -g $AppResourceGroupName --settings "keyVault_clientKey=@Microsoft.KeyVault(SecretUri=$secretId)"