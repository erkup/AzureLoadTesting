targetScope = 'subscription'
param RGname string
param location string

param webAppName string
param hostingPlanName string
param ASPskuName string
param appInsightsName string
param logWorkspaceName string
param cosmosDBname string
param loadTestingName string
param keyVaultName string


resource RG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: RGname
  location: location
}

module WebAppMod 'WebApp.bicep' = {
  scope: RG
  name: '${webAppName}.deployment'
  params: {
    appInsightsName: appInsightsName
    ASPskuName: ASPskuName
    hostingPlanName: hostingPlanName
    location: location
    logWorkspaceName: logWorkspaceName
    webAppName: webAppName
    cosmosConnString: '@Microsoft.KeyVault(VaultName=${KeyVaultMod.outputs.kvName};SecretName=${cosmosConnStringToKeyVault.outputs.cosmosConnStringSecretName})'
  }
}

module DbMod 'CosmosDB.bicep' = {
  scope: RG
  name: '${cosmosDBname}.deployment'
  params: {
    cosmosDBname: cosmosDBname
    location: location
  }
}

module KeyVaultMod 'KeyVault.bicep' = {
  scope: RG
  name: '${keyVaultName}.deployment'
  params:{
    location: location
    keyVaultName: keyVaultName
  }
}

module cosmosConnStringToKeyVault './KeyVaultSecret.bicep' = {
  scope: RG
  name: 'cosmosConnStringToKeyVault.deployment'
  params: {
    keyVaultName: KeyVaultMod.outputs.kvName
    secretName: '${DbMod.outputs.cosmosDBname}-PrimaryConnectionString'
    secretValue: listConnectionStrings('/subscriptions/adb3d052-a923-4543-a534-324e48e5a70d/resourceGroups/AzLoadTesting/providers/Microsoft.DocumentDB/databaseAccounts/azlt-cosmosdb', '2020-04-01').connectionStrings[0].connectionString
  }
  
}

module LoadTestingMod 'LoadTesting.bicep' = {
  scope: RG
  name: '${loadTestingName}.deployment'
  params: {
    loadTestingName: '${WebAppMod.outputs.webApp}-LoadTesting'
    location: 'SouthCentralUS'
  }
}
