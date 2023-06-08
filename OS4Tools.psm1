
<#
  .SYNOPSIS
  Fonction récursive pour trouver un object dans une liste (array)

  .OUTPUTS
  Index dans la liste ou -1 si pas trouvé
#>
function Find-OS4InArray
{

    [CmdletBinding()]
    param (
        [Parameter()]
        [String]$NameToFind,
        [String[]]$List,
        [Int32]$Index
    )



    if ($NameToFind -eq $List[$Index]){return $Index } 
        else { if ($index -le $List.Count) {Find-OS4InArray -NameToFind $NameToFind -List $List -Index ($index+1)} else {return -1}  }
}

<#
.SYNOPSIS

Démarrage contrôlé d'un serveur ayant le rôle Remote Desktop Services

#>
function OS4RDRestart
{

  param([String]$Server,
        [String]$Delay,
        [String]$MessageTitle,
        [String]$MessageBody,
        [String]$SessionHost
   )

    $RDUserSession = (Get-RDUserSession -ConnectionBroker $Server | Where-Object SessionStat -notlike 'STATED_DISCONNECTED'-ErrorAction SilentlyContinue)
    If ($RDUserSession.Count)
    {
      Set-RDSessionHost -ConnectionBroker $Server -NewConnectionAllowed No -SessionHost $SessionHost
  
      ForEach($_ in $RDUserSession)
      {Send-RDUserMessage -HostServer $Server -MessageTitle $MessageTitle -MessageBody $MessageBody -UnifiedSessionID $_.UnifiedSessionId}
  
      Start-Sleep -Seconds (60*$Delay)

      $RDUserSession = (Get-RDUserSession -ConnectionBroker $Server | Where-Object SessionStat -notlike 'STATED_DISCONNECTED' -ErrorAction SilentlyContinue)
      ForEach($_ in $RDUserSession)
      {Invoke-RDUserLogoff -HostServer $Server -UnifiedSessionID $_.UnifiedSessionId -Force}

      Restart-Computer -ComputerName $Server -Wait -For PowerShell -Timeout 300 -Delay 2 -Force
      Set-RDSessionHost -ConnectionBroker $Server -NewConnectionAllowed Yes -SessionHost $SessionHost 

    }
}


<#
.SYNOPSIS

Sortir le utlisateurs d'un serveur Session Host

#>
function OS4RDUserLogoff
{

<#
.SYNOPSIS

Sortir le utlisateurs d'un serveur Session Host

#>

  param([String]$Server,
        [String]$Delay,
        [String]$MessageTitle,
        [String]$MessageBody,
        [String]$SessionHost
   )

    $RDUserSession = (Get-RDUserSession -ConnectionBroker $Server | Where-Object SessionStat -notlike 'STATED_DISCONNECTED' -ErrorAction SilentlyContinue)
    If ($RDUserSession.Count)
    {
      Set-RDSessionHost -ConnectionBroker $Server -NewConnectionAllowed No -SessionHost $SessionHost
  
      ForEach($_ in $RDUserSession)
      {Send-RDUserMessage -HostServer $Server -MessageTitle $MessageTitle -MessageBody $MessageBody -UnifiedSessionID $_.UnifiedSessionId}
  
      Start-Sleep -Seconds (60*$Delay)

      $RDUserSession = (Get-RDUserSession -ConnectionBroker $Server | Where-Object SessionStat -notlike 'STATED_DISCONNECTED' -ErrorAction SilentlyContinue)
      ForEach($_ in $RDUserSession)
      {Invoke-RDUserLogoff -HostServer $Server -UnifiedSessionID $_.UnifiedSessionId -Force}

    }
}



<#
  .SYNOPSIS
  Synchronise les DCs d'un domaine

 #>
 function Start-OS4DCSync
{ 

  param()

  $LogonDC = $env:logonserver.remove(0,2)
  Invoke-Command -ScriptBlock { $DC = (Get-ADdomainController -filter *).Hostname ; ForEach($_ in $DC){repadmin /syncall $_} } -ComputerName $LogonDC


}

<#
  .SYNOPSIS
  Azure DNZ Zone Migration

  .OUTPUTS
  Supported record type

      A
      CNAME
      MX
      SRV
      TXT
 #>
function New-OS4AzDnsZoneFromDnsZone {
  param (
    [Microsoft.Azure.Commands.Profile.Models.Core.PSAzureContext] $SourceDefaultProfile,
    [Microsoft.Azure.Commands.Profile.Models.Core.PSAzureContext] $TargetDefaultProfile,
    [String] $ZoneName,
    [String] $SourceResourceGroupName,
    [String] $TargetResourceGroupName,
    [Boolean] $CreateZone,
    [System.Collections.Hashtable] $Tags
    )
 
    $SourceDNSrecords = Get-AzDnsRecordSet -ZoneName $ZoneName -ResourceGroupName $SourceResourceGroupName -DefaultProfile $SourceDefaultProfile
    if ($CreateZone){New-AzDnsZone -Name $ZoneName -ResourceGroupName $TargetResourceGroupName -ZoneType Public -Tag $Tags -DefaultProfile $TargetDefaultProfile}

    ForEach($_ in $SourceDNSrecords)
    {
      $DNSrecord = $_
      switch ($_.RecordType) {
        {$_ -contains 'A' }
                    { $Records = @()
                      $Ipv4Addresses = $DNSrecord.records.ipv4Address
                      ForEach($Ipv4 in $Ipv4Addresses){$Records += New-AzDnsRecordConfig -Ipv4Address $Ipv4 }
                    }
        {$_ -contains 'CNAME' }
                    {$Records = @()
                     $Records += New-AzDnsRecordConfig -Cname $DNSrecord.Records.Cname 
                    }
        {$_ -contains 'MX' }
                    { $Records = @()
                    $AllMX = $DNSrecord.records
                    ForEach($MX in $AllMX){$Records += New-AzDnsRecordConfig -Exchange $MX.Exchange -Preference $MX.Preference}
                    }
        {$_ -contains 'SRV' }
                    { $Records = @()
                    $AllSRV = $DNSrecord.records
                    ForEach($SRV in $AllSRV){$Records += New-AzDnsRecordConfig -Priority $SRV.Priority -Weight $SRV.Weight -Port $SRV.Port -Target $SRV.Target }
                    }
        {$_ -contains 'TXT' }
                    { $Records = @()
                    $AllTXT = $DNSrecord.records
                    ForEach($TXT in $ALLTXT){ $Records += New-AzDnsRecordConfig -Value $TXT.Value }
                    }
        Default { Write-Host 'Record type ' $_ ' not supported'}
      } 
      If ($DNSRecord.RecordType -in ('A','CNAME','MX','SRV','TXT')){
      New-AzDnsRecordSet `
        -Name $DNSRecord.Name `
        -RecordType $DNSRecord.RecordType `
        -ResourceGroupName $TargetResourceGroupName `
        -TTL $DNSrecord.TTL `
        -ZoneName $ZoneName `
        -DnsRecord $Records `
        -DefaultProfile $TargetDefaultProfile
      }
        
    }
}

<#
.SYNOPSIS

Attendre qu'une "Subscription" soit attachée à "Tenant"

#>
function Wait-OS4Subscription
{

 param([String]$Subscription,
        [String]$TargeTenantId
      )

    For( $i= 0 ; (Get-AzSubscription -SubscriptionID $Subscription -WarningAction SilentlyContinue).TenantID -NE $TargetTenantId ; $i++)
       {Write-Host"$i minute(s)";Start-Sleep-seconds 60}
  

}

<#
.SYNOPSIS

Obtenir l'information du dernière démarrage

#>
function Get-OS4LastRestart
{

 param([String]$Computer
       )

    (Get-WinEvent -FilterHashtable @{logname = 'System'; id = 1074} -Computer $Computer)[0].TimeCreated
       
}
<#
.SYNOPSIS

Valider si un utilisateur s'est authentifié (Selon la capacité du EventLog)
Voir 

#>
function Search-OS4ADUserInEventLog
{

 param([String]$Identity)
 
 $Find = $false

    $DCs = (Get-ADDomainController -Filter *).hostName
    ForEach($_ in $DCs)
    {
      If (!$Find) {
        $Messages = (Get-eventlog -LogName Security -ComputerName $_ | where-object {$_.EventID -eq 4624})
        ForEach($MSG in $Messages){if ($MSG.Message.Contains($Identity)){Write-Host "Active";$Find=$True;Break;}}
      }
    }
  
  If (!$Find){Write-Host "Aucune activité trouvée"}
  
}