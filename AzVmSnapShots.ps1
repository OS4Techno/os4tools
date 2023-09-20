<#

Création de Snapshots pour les disques de la VM  ($VMtoSave) et en conserver un nombre spécifique ($NumberToKeep) selon le type($RetentionType).

Pour utilisation avec Azure Automation Account

$RentionType
    J = Journalier (Daily)
    H = Hebdomadaire (Weekly)
    M = Mensuel (Monthly)
    A = Annuel (Yearly)

#>

param   (
        [Parameter(Mandatory)] [string] $VmToSave, 
        [Parameter(Mandatory)] [string] $VmResourceGroup, 
        [Parameter(Mandatory)] [string] $RetentionType, 
        [Parameter(Mandatory)] [Int16] $NumberToKeep, 
        [Parameter(Mandatory)] [string] $ResourceGroupStore 
        )

$SubscriptionID = '' # ID de la subscription

Import-Module Az.Accounts
Import-Module Az.Resources
Import-Module Az.Automation
Import-Module Az.Monitor
Import-Module Az.Compute

Disable-AzContextAutosave -Scope Process
$AzureContext = (Connect-AzAccount -Identity -Subscription $SubscriptionID).context


# Validation
try {
    Get-AzResourceGroup -ResourceGroupName $VmResourceGroup -ErrorAction Continue
}
catch { Write-Output "VM Resource Group invalide!";Return}

try {
    Get-AzResourceGroup -ResourceGroupName $ResourceGroupStore -ErrorAction Continue
}
catch { Write-Output "Store Resource Group invalide!";Return}

try {
        Get-AzVM -Name $VmToSave -ResourceGroupName $VmResourceGroup -ErrorAction Continue    
}
catch { Write-Output "Nom de VM invalide!";Return}

if ($RetentionType -notin ("J","H","M","A")) { Write-Output "Type invalide!" ; Return}

# Traitement

$SnapshotPrefix = (Get-Date -DisplayHint Date -format "yyyMMddhhmm_")+$RetentionType+"_"+$VmToSave+"_"
$Tags =  @{"Created by"="Automation Account"; "ms-resource-usage"=$VmToSave}

$Disks = (Get-AzDisk | Where-Object DiskState -Contains 'Attached')
$NumberOfDisks = 0
ForEach($_ in $Disks){if ($_.Managedby.Split('/')[8] -Contains $VmToSave)
    {
        $NumberOfDisks++
        $SnapShotConfig = New-AzSnapShotConfig -SourceResourceID $_.ID -Location $_.Location -CreateOption Copy
        New-AzSnapShot -ResourceGroupName $ResourceGroupStore -SnapShotName ($SnapshotPrefix+$NumberOfDisks) -SnapShot $SnapShotConfig
    }
    }

$NumberOfDisks = $NumberOfDisks * $NumberToKeep
$Patern='*_'+$RetentionType+'_'+$VmToSave+'*'

$SnapshotInventory = ((Get-AzSnapshot -ResourceGroupName $ResourceGroupStore | Where-Object Name -like $Patern) | Sort-Object Name -Descending)
$index = 0
For($index = $NumberOfDisks ; $index -LT $SnapshotInventory.Count; $index++)
    {
        Remove-AzSnapShot -ResourceGroupName $ResourceGroupStore -SnapshotName $SnapshotInventory[$index].Name -Force -Confirm:$False
    }
