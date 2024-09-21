# ******************************* environment specific variable arguments ***********************************
param (
    $functionsAppEnvironment,
	$cloudLocation,
	$functionsNamePrefix,
	$baseFolder,
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
$functionsAppName=$functionsNamePrefix+$functionsAppVersion+"-"+$cloudLocation+"-$resourceType-"+$functionsAppEnvironment
$functionsResourceGroupName="ssmyapp-"+$cloudLocation+"-rg-"+$functionsAppEnvironment
#------------------------------------------------------------------------------------------------------------

# ******************************* prepare arm teplate parameter files ***************************************
Function FilterFile($FilePath){
    $FilePathFiltered=$FilePath+'.tmp'
    (Get-Content $FilePath -Raw) `
    -replace '\$\(TARGET_APP_SERVICE_RESOURCE_GROUP\)', $functionsResourceGroupName `
    -replace '\$\(TARGET_APP_SERVICE_NAME\)', $functionsAppName `
    -replace '\$\(TARGET_APP_SERVICE_ENVIRONMENT\)', $functionsAppEnvironment `
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
echo "TARGET_APP_SERVICE_LOCATION=$cloudLocation" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
echo "TARGET_APP_SERVICE_VERSION=$functionsAppVersion" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
echo "TARGET_CODE_VERSION=$functionsAppVersionActual" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
echo "SOURCE_FOLDER_ARTIFACT=$baseFolder" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf8 -Append
#------------------------------------------------------------------------------------------------------------

# ******************************* Prints variables **********************************************************
Write-Host "Target Resource Group       :" $functionsResourceGroupName
Write-Host "Target App Service Name     :" $functionsAppName
Write-Host "Target App Environment      :" $functionsAppEnvironment
Write-Host "target Location             :" $cloudLocation
Write-Host "Application Version         :" $functionsAppVersion
Write-Host "Application Version Actuals :" $functionsAppVersionActual
#------------------------------------------------------------------------------------------------------------