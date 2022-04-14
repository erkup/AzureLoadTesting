param loadTestingName string
param location string
param LoadTesterObjId string

resource LoadTesting 'Microsoft.LoadTestService/loadTests@2021-12-01-preview' = {
  name: loadTestingName
  location: location
}

resource roleAssignLoadTestContributor 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name: guid(LoadTesterObjId,'749a398d-560b-491b-bb21-08924219302e')
  scope: LoadTesting
  properties: {
    principalId: LoadTesterObjId
    roleDefinitionId: '749a398d-560b-491b-bb21-08924219302e'
  }
}
