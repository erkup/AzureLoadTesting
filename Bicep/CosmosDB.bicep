param cosmosDBname string
param location string


resource cosmosDB 'Microsoft.DocumentDB/databaseAccounts@2021-11-15-preview' = {
  kind: 'MongoDB'
  name: cosmosDBname
  location: location
  properties: {
    databaseAccountOfferType: 'Standard'
    locations:[
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
  }
}

resource sampleDB 'Microsoft.DocumentDB/databaseAccounts/mongodbDatabases@2021-11-15-preview' = {
  name: '${cosmosDB.name}/sampleDB'
  properties: {
    resource: {
      id: 'sampleDB'
    }
    options: {
      throughput: 400
    }
  }
}

resource sampleCollection 'Microsoft.DocumentDB/databaseAccounts/mongodbDatabases/collections@2021-11-15-preview' = {
  name: '${sampleDB.name}/sampleCollection'
  properties: {
    resource: {
      id: 'sampleCollection'
      indexes: [
        {
          key:{
            keys:[
              '_id'
            ]
          }
        }
      ]
    }
    options: {}
  }

}

output cosmosDBnameOutput string = cosmosDB.name
output cosmosDBresourceID string = cosmosDB.id
