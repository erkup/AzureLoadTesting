targetScope = 'subscription'
param RGname string
param location string

param webAppPrefix string
param hostingPlanName string
param ASPskuName string
param appInsightsName string
param logWorkspaceName string
param cosmosDBprefix string
param loadTestingName string
param keyVaultPrefix string
param LoadTesterObjId string

resource RG 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: RGname
  location: location
}

module WebAppMod 'WebApp.bicep' = {
  scope: RG
  name: '${webAppPrefix}.deployment'
  params: {
    appInsightsName: appInsightsName
    ASPskuName: ASPskuName
    hostingPlanName: hostingPlanName
    location: location
    logWorkspaceName: logWorkspaceName
    webAppPrefix: webAppPrefix
    kvName: KeyVaultMod.outputs.kvName
    secretName: DbMod.outputs.secretName
  }
}

module DbMod 'CosmosDB.bicep' = {
  scope: RG
  name: '${cosmosDBprefix}.deployment'
  dependsOn: [
    KeyVaultMod
  ]
  params: {
    cosmosDBprefix: cosmosDBprefix
    location: location
    kvName: KeyVaultMod.outputs.kvName
  }
}

module KeyVaultMod 'KeyVault.bicep' = {
  scope: RG
  name: '${keyVaultPrefix}.deployment'
  params:{
    location: location
    keyVaultPrefix: keyVaultPrefix 
  }
}
module WebAppKVaccess 'KeyVaultAccess.bicep' = {
  scope: RG
  name: 'WebAppKVaccess.deployment'
  params: {
    kvName: KeyVaultMod.outputs.kvName
    webAppIdentity: WebAppMod.outputs.webAppIdentity
  }
}

module LoadTestingMod 'LoadTesting.bicep' = {
  scope: RG
  name: '${loadTestingName}.deployment'
  params: {
    loadTestingName: '${WebAppMod.outputs.webApp}-LoadTesting'
    location: 'SouthCentralUS'
    LoadTesterObjId: LoadTesterObjId
  }
}
