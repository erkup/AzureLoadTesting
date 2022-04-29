param webAppPrefix string
param hostingPlanName string
param ASPskuName string
param location string
param appInsightsName string
param logWorkspaceName string
param kvName string
param secretName string 

var webAppName = take('${webAppPrefix}${uniqueString(resourceGroup().id)}',15)

resource webApp 'Microsoft.Web/sites@2021-03-01' = {
  name: webAppName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    siteConfig: {
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '14.16.0'
        }
        {
          name: 'MSDEPLOY_RENAME_LOCKED_FILES'
          value: '1'
        }
        {
          name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
          value: 'true'
        }
        {
          name: 'CONNECTION_STRING'
          value: '@Microsoft.KeyVault(SecretUri=https://${kvName}.vault.azure.net/secrets/${secretName}'
        }
      ]
      phpVersion: '7.1'
    }
    serverFarmId: appServicePlan.id
  }
}


resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: ASPskuName
  }
  kind: 'app'
}

/* resource appInsightsExtension 'Microsoft.Web/sites/siteextensions@2021-03-01' = {
  name: '${webApp.name}/Microsoft.ApplicationInsights.AzureWebsites'
} */

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'string'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logWorkspace.id
  }
}

resource logWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: logWorkspaceName
  location: location
}

output webApp string = webApp.name
output webAppIdentity string = webApp.identity.principalId
