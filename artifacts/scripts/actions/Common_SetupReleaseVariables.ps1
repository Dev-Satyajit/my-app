# ******************************* environment specific variable arguments ***********************************
param (
    $functionsAppEnvironment,
    $networkEnvironment,
	$cloudLocation,
	$functionsNamePrefix,
	$baseFolder,
	$releaseNumber,
	$resourceType = 'fa'
)
#------------------------------------------------------------------------------------------------------------

# ******************************* prepare pipeline variables ************************************************
$filePath = $baseFolder+"/pom.xml"
Write-Host $filePath
[xml]$pomXml = Get-Content $filePath
$functionsAppVersionActual=""+$pomXml.project.version
$functionsAppVersionRaw=$pomXml.project.version -replace '[^a-zA-Z\d\s:]'
$functionsAppVersion=$functionsAppVersionRaw.ToLower()
if ($functionsAppEnvironment -eq $null) {
    Write-Host "No app environment argument found. Reading from pom file........."
    $functionsAppEnvironment=$pomXml.project.properties.targetEnvironment
}
if ($networkEnvironment -eq $null) {
    Write-Host "No network environment argument found. Reading from pom file........."
    $networkEnvironment=$pomXml.project.properties.targetNetworkEnvironment
}
$functionsAppName=$functionsNamePrefix+$functionsAppVersion+"-"+$cloudLocation+"-$resourceType-"+$functionsAppEnvironment
$functionsResourceGroupName="myapp-"+$cloudLocation+"-rg-"+$functionsAppEnvironment
#------------------------------------------------------------------------------------------------------------

# ******************************* prepare arm teplate parameter files ***************************************
Function FilterFile($FilePath){
    $FilePathFiltered=$FilePath+'.tmp'
    (Get-Content $FilePath -Raw) `
    -replace '\$\(TARGET_APP_SERVICE_RESOURCE_GROUP\)', $functionsResourceGroupName `
    -replace '\$\(TARGET_APP_SERVICE_NAME\)', $functionsAppName `
    -replace '\$\(TARGET_APP_SERVICE_ENVIRONMENT\)', $functionsAppEnvironment `
    -replace '\$\(TARGET_NETWORK_ENVIRONMENT\)', $networkEnvironment `
    -replace '\$\(TARGET_APP_SERVICE_VERSION\)', $functionsAppVersion `
    -replace '\$\(TARGET_APP_SERVICE_LOCATION\)', $cloudLocation `
    -replace '\$\(TARGET_CODE_VERSION\)', $functionsAppVersionActual `
     | Set-Content $FilePathFiltered
}

Get-ChildItem ($baseFolder+"/artifacts/templates/params") -rec -Filter *.json | 
Foreach-Object {
    Write-Host "$_"
    FilterFile $_.FullName
}
#------------------------------------------------------------------------------------------------------------

# ******************************* set parameters as environment variables ***********************************
echo "TARGET_APP_SERVICE_RESOURCE_GROUP=$functionsResourceGroupName"  | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
echo "TARGET_APP_SERVICE_NAME=$functionsAppName" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
echo "TARGET_APP_SERVICE_ENVIRONMENT=$functionsAppEnvironment" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
echo "TARGET_NETWORK_ENVIRONMENT=$networkEnvironment " | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
echo "TARGET_APP_SERVICE_LOCATION=$cloudLocation" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
echo "TARGET_APP_SERVICE_VERSION=$functionsAppVersion" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
echo "TARGET_CODE_VERSION=$functionsAppVersionActual" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
echo "SOURCE_FOLDER_ARTIFACT=$baseFolder" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append

$filePath = $baseFolder+"/infrastructure_changed.txt"
if([System.IO.File]::Exists($filePath)){
    $infra = 'True'
    Write-Host "INFRA_CHANGED=True" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
}
#------------------------------------------------------------------------------------------------------------

# ******************************* Prints variables **********************************************************
Write-Host "Target Resource Group       :" $functionsResourceGroupName
Write-Host "Target App Service Name     :" $functionsAppName
Write-Host "Target App Environment      :" $functionsAppEnvironment
Write-Host "Target Network Environment  :" $networkEnvironment
Write-Host "target Location             :" $cloudLocation
Write-Host "Application Version         :" $functionsAppVersion
Write-Host "Application Version Actuals :" $functionsAppVersionActual
Write-Host "Infra Flag                  :" $infra
#------------------------------------------------------------------------------------------------------------

# ******************************* Dump variables ************************************************************
$releasefileName = 'release-params'+$releaseNumber+'.txt'
Write-Host "Variable file :" $releasefileName
$content = "TARGET_APP_SERVICE_RESOURCE_GROUP="+$functionsResourceGroupName+"`n"+
           "TARGET_APP_SERVICE_NAME="+$functionsAppName+"`n"+
           "TARGET_APP_SERVICE_ENVIRONMENT="+$functionsAppEnvironment+"`n"+
           "TARGET_NETWORK_ENVIRONMENT="+$networkEnvironment+"`n"+
           "TARGET_APP_SERVICE_LOCATION="+$cloudLocation+"`n"+
           "TARGET_APP_SERVICE_VERSION="+$functionsAppVersion+"`n"+
           "TARGET_CODE_VERSION="+$functionsAppVersionActual | Set-Content $releasefileName