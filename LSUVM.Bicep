param virtualMachines_LSUAZRCHUBB01_name string = 'LSUAZRCHUBB01'
param disks_LSUAZRCHUBB01_OsDisk_1_e8fb84ff998c471896898aec5f10fd9a_externalid string = '/subscriptions/2651fc56-d9f4-445b-bd40-9a92944b6781/resourceGroups/IaaSCC/providers/Microsoft.Compute/disks/LSUAZRCHUBB01_OsDisk_1_e8fb84ff998c471896898aec5f10fd9a'
param disks_LSUAZRCHUBB01_DataDisk_0_externalid string = '/subscriptions/2651fc56-d9f4-445b-bd40-9a92944b6781/resourceGroups/IaaSCC/providers/Microsoft.Compute/disks/LSUAZRCHUBB01_DataDisk_0'
param networkInterfaces_lsuazrchubb01480_z1_externalid string = '/subscriptions/2651fc56-d9f4-445b-bd40-9a92944b6781/resourceGroups/IaaSCC/providers/Microsoft.Network/networkInterfaces/lsuazrchubb01480_z1'

resource virtualMachines_LSUAZRCHUBB01_name_resource 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: virtualMachines_LSUAZRCHUBB01_name
  location: 'canadacentral'
  tags: {
    'Created by': 'Michel Caron'
    Roles: 'CHUBB Laval'
    Usage: 'Production'
  }
  zones: [
    '1'
  ]
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-datacenter-gensecond'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        name: '${virtualMachines_LSUAZRCHUBB01_name}_OsDisk_1_e8fb84ff998c471896898aec5f10fd9a'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
          id: disks_LSUAZRCHUBB01_OsDisk_1_e8fb84ff998c471896898aec5f10fd9a_externalid
        }
        deleteOption: 'Delete'
        diskSizeGB: 127
      }
      dataDisks: [
        {
          lun: 0
          name: '${virtualMachines_LSUAZRCHUBB01_name}_DataDisk_0'
          createOption: 'Attach'
          caching: 'ReadOnly'
          writeAcceleratorEnabled: false
          managedDisk: {
            storageAccountType: 'Premium_LRS'
            id: disks_LSUAZRCHUBB01_DataDisk_0_externalid
          }
          deleteOption: 'Detach'
          diskSizeGB: 128
          toBeDetached: false
        }
      ]
    }
    osProfile: {
      computerName: virtualMachines_LSUAZRCHUBB01_name
      adminUsername: 'AdminLSU'
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: false
        patchSettings: {
          patchMode: 'Manual'
          assessmentMode: 'ImageDefault'
          enableHotpatching: false
        }
        enableVMAgentPlatformUpdates: false
      }
      secrets: []
      allowExtensionOperations: true
      requireGuestProvisionSignal: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaces_lsuazrchubb01480_z1_externalid
          properties: {
            deleteOption: 'Detach'
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}
