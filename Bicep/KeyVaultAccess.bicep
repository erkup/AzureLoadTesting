param webAppIdentity string
param kvName string

//this is to grant access for the system-assigned identity of the WebApp on the KeyVault in order to reference the ConnectionString secret in the KeyVault from the AppSetting

resource GrantWebApptoKV 'Microsoft.KeyVault/vaults/accessPolicies@2021-11-01-preview' = {
  name: '${kvName}/add'
  properties: {
    accessPolicies: [
      {
        permissions: {
          secrets:[
            'get'
          ]
        }
        tenantId: tenant().tenantId
        objectId: webAppIdentity
      }
    ]
  }
}

