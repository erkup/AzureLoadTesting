param kvName string
param secretName string
@secure()
param secretValue string

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${kvName}/${secretName}' 
  properties: {
    value: secretValue
  }
}

output cosmosConnStringSecretName string = secretName
