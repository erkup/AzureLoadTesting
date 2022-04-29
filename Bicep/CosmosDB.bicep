param cosmosDBprefix string
param location string
param kvName string

var cosmosDBname = take('${cosmosDBprefix}${uniqueString(resourceGroup().id)}',15)
var secretName = '${cosmosDBname}-PrimaryConnectionString'

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${kvName}/${secretName}' 
  dependsOn: [
    sampleCollection
    sampleDB
  ]
  properties: {
    value: listConnectionStrings('Microsoft.DocumentDB/databaseAccounts/${cosmosDBname}', '2020-04-01').connectionStrings[0].connectionString
  }
}

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

output cosmosDBname string = cosmosDB.name
output cosmosDBresourceID string = cosmosDB.id
output secretName string = secretName
