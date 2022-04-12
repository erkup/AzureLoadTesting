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
    cosmosConnString: cosmosConnStringToKeyVault.outputs.keyVaultSecretValue
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

module KeyVault 'KeyVault.bicep' = {
  scope: RG
  name: '${keyVaultName}.deployment'
  params: {
    keyVaultName: keyVaultName
    location: location
  }
}
module cosmosConnStringToKeyVault './KeyVaultSecret.bicep' = {
  scope: RG
  name: 'cosmosConnStringToKeyVault.deployment'
  params: {
    keyVaultName: KeyVault.outputs.kvName
    secretName: '${DbMod.outputs.cosmosDBnameOutput}-PrimaryConnectionString'
    secretValue: listConnectionStrings(resourceId('AzLoadTesting/providers/Microsoft.DocumentDB/databaseAccounts', cosmosDBname), '2020-04-01').connectionStrings[0].connectionString
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
