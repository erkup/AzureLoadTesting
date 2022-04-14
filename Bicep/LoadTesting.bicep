param loadTestingName string
param location string
param LoadTesterObjId string

resource LoadTesting 'Microsoft.LoadTestService/loadTests@2021-12-01-preview' = {
  name: loadTestingName
  location: location
}


resource LoadTesterRoleDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  name: '749a398d-560b-491b-bb21-08924219302e'
  scope: subscription()
}

resource roleAssignLoadTestContributor 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(resourceGroup().id,LoadTesterObjId,LoadTesterRoleDefinition.id)
  scope: LoadTesting
  properties: {
    principalId: LoadTesterObjId
    principalType: 'User'
    roleDefinitionId: LoadTesterRoleDefinition.id
  }
}
