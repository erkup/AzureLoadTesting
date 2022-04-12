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
    cosmosConnString: KeyVault.getSecret('${cosmosConnStringToKeyVault.outputs.cosmosConnStringSecretName}')
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

resource KeyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  scope: RG
  name: keyVaultName
}

module cosmosConnStringToKeyVault './KeyVaultSecret.bicep' = {
  scope: resourceGroup(subscription().subscriptionId,RG.name)
  name: 'cosmosConnStringToKeyVault.deployment'
  params: {
    keyVaultName: KeyVault.name
    secretName: '${DbMod.outputs.cosmosDBname}-PrimaryConnectionString'
    secretValue: listConnectionStrings(resourceId('Microsoft.DocumentDB/databaseAccounts', cosmosDBname), '2020-04-01').connectionStrings[0].connectionString
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
