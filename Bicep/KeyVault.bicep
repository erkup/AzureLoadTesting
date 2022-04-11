param keyVaultName string
param location string

resource KeyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family:'A'
      name: 'standard'
    }
    enabledForTemplateDeployment:true
    tenantId: tenant().tenantId
  }
}

output kvName string = KeyVault.name
