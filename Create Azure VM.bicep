param vaults_MichelCaron_name string
param virtualMachines_McLabDC01_name string
param networkInterfaces_mcdc01573_name string
param publicIPAddresses_McDC01_ip_name string
param virtualNetworks_McDC01_vnet_name string
param networkInterfaces_mclabdc0127_name string
param networkSecurityGroups_McDC01_nsg_name string
param networkSecurityGroups_McLabDC01_nsg_name string
param schedules_shutdown_computevm_mclabdc01_name string

resource vaults_MichelCaron_name_resource 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: vaults_MichelCaron_name
  location: 'canadacentral'
  properties: {
    sku: {
      family: 'A'
      name: 'Standard'
    }
    tenantId: '1f7e1762-8fbb-4bee-a9d4-16f6f7889612'
    accessPolicies: [
      {
        tenantId: '1f7e1762-8fbb-4bee-a9d4-16f6f7889612'
        objectId: '01e965be-de0a-4011-8f92-10f25ed84f10'
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
            'GetRotationPolicy'
            'SetRotationPolicy'
            'Rotate'
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
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: false
    vaultUri: 'https://michelcaron.vault.azure.net/'
    provisioningState: 'Succeeded'
    publicNetworkAccess: 'Enabled'
  }
}

resource networkSecurityGroups_McDC01_nsg_name_resource 'Microsoft.Network/networkSecurityGroups@2023-06-01' = {
  name: networkSecurityGroups_McDC01_nsg_name
  location: 'canadacentral'
  properties: {
    securityRules: [
      {
        name: 'RDP'
        id: networkSecurityGroups_McDC01_nsg_name_RDP.id
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 300
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

resource networkSecurityGroups_McLabDC01_nsg_name_resource 'Microsoft.Network/networkSecurityGroups@2023-06-01' = {
  name: networkSecurityGroups_McLabDC01_nsg_name
  location: 'canadacentral'
  properties: {
    securityRules: [
      {
        name: 'RDP'
        id: networkSecurityGroups_McLabDC01_nsg_name_RDP.id
        type: 'Microsoft.Network/networkSecurityGroups/securityRules'
        properties: {
          protocol: 'TCP'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 300
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
}

resource publicIPAddresses_McDC01_ip_name_resource 'Microsoft.Network/publicIPAddresses@2023-06-01' = {
  name: publicIPAddresses_McDC01_ip_name
  location: 'canadacentral'
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    ipAddress: '20.104.67.23'
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

resource virtualNetworks_McDC01_vnet_name_resource 'Microsoft.Network/virtualNetworks@2023-06-01' = {
  name: virtualNetworks_McDC01_vnet_name
  location: 'canadacentral'
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        id: virtualNetworks_McDC01_vnet_name_default.id
        properties: {
          addressPrefix: '10.0.0.0/24'
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

resource virtualMachines_McLabDC01_name_resource 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: virtualMachines_McLabDC01_name
  location: 'canadacentral'
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2as_v4'
    }
    additionalCapabilities: {
      hibernationEnabled: false
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        name: '${virtualMachines_McLabDC01_name}_OsDisk_1_0257ed76f3184a949f02d9b654e30d50'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          id: resourceId('Microsoft.Compute/disks', '${virtualMachines_McLabDC01_name}_OsDisk_1_0257ed76f3184a949f02d9b654e30d50')
        }
        deleteOption: 'Delete'
      }
      dataDisks: []
      diskControllerType: 'SCSI'
    }
    osProfile: {
      computerName: virtualMachines_McLabDC01_name
      adminUsername: 'adminlab'
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
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
          id: networkInterfaces_mclabdc0127_name_resource.id
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

resource schedules_shutdown_computevm_mclabdc01_name_resource 'microsoft.devtestlab/schedules@2018-09-15' = {
  name: schedules_shutdown_computevm_mclabdc01_name
  location: 'canadacentral'
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '1900'
    }
    timeZoneId: 'UTC'
    notificationSettings: {
      status: 'Enabled'
      timeInMinutes: 30
      emailRecipient: 'Michel.Caron@os4techno.com'
      notificationLocale: 'en'
    }
    targetResourceId: virtualMachines_McLabDC01_name_resource.id
  }
}

resource vaults_MichelCaron_name_Polymos 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: vaults_MichelCaron_name_resource
  name: 'Polymos'
  location: 'canadacentral'
  properties: {
    attributes: {
      enabled: true
    }
  }
}

resource networkSecurityGroups_McDC01_nsg_name_RDP 'Microsoft.Network/networkSecurityGroups/securityRules@2023-06-01' = {
  name: '${networkSecurityGroups_McDC01_nsg_name}/RDP'
  properties: {
    protocol: 'TCP'
    sourcePortRange: '*'
    destinationPortRange: '3389'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 300
    direction: 'Inbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
  dependsOn: [
    networkSecurityGroups_McDC01_nsg_name_resource
  ]
}

resource networkSecurityGroups_McLabDC01_nsg_name_RDP 'Microsoft.Network/networkSecurityGroups/securityRules@2023-06-01' = {
  name: '${networkSecurityGroups_McLabDC01_nsg_name}/RDP'
  properties: {
    protocol: 'TCP'
    sourcePortRange: '*'
    destinationPortRange: '3389'
    sourceAddressPrefix: '*'
    destinationAddressPrefix: '*'
    access: 'Allow'
    priority: 300
    direction: 'Inbound'
    sourcePortRanges: []
    destinationPortRanges: []
    sourceAddressPrefixes: []
    destinationAddressPrefixes: []
  }
  dependsOn: [
    networkSecurityGroups_McLabDC01_nsg_name_resource
  ]
}

resource virtualNetworks_McDC01_vnet_name_default 'Microsoft.Network/virtualNetworks/subnets@2023-06-01' = {
  name: '${virtualNetworks_McDC01_vnet_name}/default'
  properties: {
    addressPrefix: '10.0.0.0/24'
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  dependsOn: [
    virtualNetworks_McDC01_vnet_name_resource
  ]
}

resource networkInterfaces_mcdc01573_name_resource 'Microsoft.Network/networkInterfaces@2023-06-01' = {
  name: networkInterfaces_mcdc01573_name
  location: 'canadacentral'
  kind: 'Regular'
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        id: '${networkInterfaces_mcdc01573_name_resource.id}/ipConfigurations/ipconfig1'
        etag: 'W/"19e867f1-845b-4b3a-b58b-773414054ebc"'
        type: 'Microsoft.Network/networkInterfaces/ipConfigurations'
        properties: {
          provisioningState: 'Succeeded'
          privateIPAddress: '10.0.0.4'
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: virtualNetworks_McDC01_vnet_name_default.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: true
    enableIPForwarding: false
    disableTcpStateTracking: false
    networkSecurityGroup: {
      id: networkSecurityGroups_McDC01_nsg_name_resource.id
    }
    nicType: 'Standard'
    auxiliaryMode: 'None'
    auxiliarySku: 'None'
  }
}

resource networkInterfaces_mclabdc0127_name_resource 'Microsoft.Network/networkInterfaces@2023-06-01' = {
  name: networkInterfaces_mclabdc0127_name
  location: 'canadacentral'
  kind: 'Regular'
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        id: '${networkInterfaces_mclabdc0127_name_resource.id}/ipConfigurations/ipconfig1'
        etag: 'W/"8bbe65fb-d44b-440e-ab4f-355d6a0c7077"'
        type: 'Microsoft.Network/networkInterfaces/ipConfigurations'
        properties: {
          provisioningState: 'Succeeded'
          privateIPAddress: '10.0.0.5'
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_McDC01_ip_name_resource.id
          }
          subnet: {
            id: virtualNetworks_McDC01_vnet_name_default.id
          }
          primary: true
          privateIPAddressVersion: 'IPv4'
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: true
    enableIPForwarding: false
    disableTcpStateTracking: false
    networkSecurityGroup: {
      id: networkSecurityGroups_McLabDC01_nsg_name_resource.id
    }
    nicType: 'Standard'
    auxiliaryMode: 'None'
    auxiliarySku: 'None'
  }
}
