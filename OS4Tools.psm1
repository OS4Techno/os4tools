function Find-OS4InArray
{

    [CmdletBinding()]
    param (
        [Parameter()]
        [String]$NameToFind,
        [String[]]$List,
        [Int32]$Index
    )

<#
  .NAME
  Find-OS4InArray

  .SYNOPSIS
  Fonction récursive pour trouver un object dans une liste (array)

  .OUTPUTS
  Index dans la liste ou -1 si pas trouvé
#>

    if ($NameToFind -eq $List[$Index]){return $Index } 
        else { if ($index -lt $List.Count) {Find-OS4InArray -NameToFind $NameToFind -List $List -Index ($index+1)} else {return -1}  }
}

function OS4RDRestart
{

  param([String]$Server,
        [String]$Delay,
        [String]$MessageTitle,
        [String]$MessageBody,
        [String]$SessionHost
   )

<#
.SYNOPSIS

Démarrage contrôlé d'un serveur ayant le rôle Remote Desktop Services

#>

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


function Start-OS4DCSync
{

<#
.SYNOPSIS

Synchronise les DCs d'un domaine

.NAME
  Sart-OS4DCSync

#>

  param()

  $LogonDC = $env:logonserver.remove(0,2)
  Invoke-Command -ScriptBlock { $DC = (Get-ADdomainController -filter *).Hostname ; ForEach($_ in $DC){repadmin /syncall $_} } -ComputerName $LogonDC


}
