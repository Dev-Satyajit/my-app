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
$functionsResourceGroupName="myapp-"+$cloudLocation+"-rg-"+$functionsAppEnvironment
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
Write-Host "##vso[task.setvariable variable=TARGET_APP_SERVICE_RESOURCE_GROUP]$functionsResourceGroupName"
Write-Host "##vso[task.setvariable variable=TARGET_APP_SERVICE_NAME]$functionsAppName"
Write-Host "##vso[task.setvariable variable=TARGET_APP_SERVICE_ENVIRONMENT]$functionsAppEnvironment"
Write-Host "##vso[task.setvariable variable=TARGET_APP_SERVICE_LOCATION]$cloudLocation"
Write-Host "##vso[task.setvariable variable=TARGET_APP_SERVICE_VERSION]$functionsAppVersion"
Write-Host "##vso[task.setvariable variable=TARGET_CODE_VERSION]$functionsAppVersionActual"
Write-Host "##vso[task.setvariable variable=SOURCE_FOLDER_ARTIFACT]$baseFolder"
#------------------------------------------------------------------------------------------------------------

# ******************************* Prints variables **********************************************************
Write-Host "Target Resource Group       :" $functionsResourceGroupName
Write-Host "Target App Service Name     :" $functionsAppName
Write-Host "Target App Environment      :" $functionsAppEnvironment
Write-Host "target Location             :" $cloudLocation
Write-Host "Application Version         :" $functionsAppVersion
Write-Host "Application Version Actuals :" $functionsAppVersionActual
#------------------------------------------------------------------------------------------------------------