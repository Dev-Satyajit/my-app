param (
   $AppResourceGroupName,
   $AppName,
   $CommaSeparatedKeyValues
)

$KeyValues = $CommaSeparatedKeyValues.Split(",")
foreach ($KeyValue in $KeyValues) {
	az functionapp config appsettings set -n $AppName -g $AppResourceGroupName --settings $KeyValue
}