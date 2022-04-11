param loadTestingName string
param location string

resource LoadTesting 'Microsoft.LoadTestService/loadTests@2021-12-01-preview' = {
  name: loadTestingName
  location: location
}
