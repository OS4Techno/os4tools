param SubnetServer string =  'AzServeur'
param VmName string = 'McTest'
param Location string = 'CanadaCentral'
param Autor string = 'Michel'

resource Subnet 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' existing = {
  name: SubnetServer
}
// Creation d'une VM pour un "Subnet" précis
resource VM 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: VmName
  location: Location
  tags: {
     'Created by': Autor
  }
  properties: {
// Networking
    networkProfile: {
      networkApiVersion: '2020-11-01'
      networkInterfaceConfigurations: [
        {
          name: 'McTestNIC01'
          properties: {
            deleteOption: 'Delete'
            enableAcceleratedNetworking: true
            ipConfigurations: [
              {
                name: 'ipconfig01'
                properties: {
                  primary: true
                  privateIPAddressVersion: 'IPv4'
                  subnet: {
                    id: Subnet.id
                  }
                }
              }
            ]
            primary: true
          }
        }
      ]
    }
// Windows
  osProfile: {
    adminPassword: AdminPolymos
    adminUsername: Welcome.2023
    allowExtensionOperations: true
    computerName: VmName
    }
// Disques
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        
      }
      
    }



  }
}
