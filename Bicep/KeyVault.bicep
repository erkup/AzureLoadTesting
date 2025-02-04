param keyVaultPrefix string
param location string
param accessPolicies array = [
  {
    tenantId: tenant().tenantId
    objectId: '5ef97f1e-3d5e-4364-8417-24808317b1fb'
    permissions: {
      keys: [
        'Get'
        'List'
        'Update'
        'Create'
        'Import'
        'Delete'
        'Recover'
        'Backup'
        'Restore'
      ]
      secrets: [
        'Get'
        'List'
        'Set'
        'Delete'
        'Recover'
        'Backup'
        'Restore'
      ]
      certificates: [
        'Get'
        'List'
        'Update'
        'Create'
        'Import'
        'Delete'
        'Recover'
        'Backup'
        'Restore'
        'ManageContacts'
        'ManageIssuers'
        'GetIssuers'
        'ListIssuers'
        'SetIssuers'
        'DeleteIssuers'
      ]
    }
  }
]

var kvName = take('${keyVaultPrefix}${uniqueString(resourceGroup().id)}',15)

resource KeyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: kvName
  location: location
  properties: {
    sku: {
      family:'A'
      name: 'standard'
    }
    accessPolicies: accessPolicies
    enabledForTemplateDeployment:true
    tenantId: tenant().tenantId
    enableSoftDelete: false
  }
}

output kvName string = KeyVault.name
output kvResourceId string = KeyVault.id
