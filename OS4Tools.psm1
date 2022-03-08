function OS4FindInArray
{

<#
.SYNOPSYS

Fonction récursive pour trouver un object dans une liste (array)

#>
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $NameToFind,
        [String[]]$List,
        [Int32]$Index
    )

    if ($NameToFind -eq $List[$Index]){return $True } 
        else { if ($index -lt $List.Count) {OS4FindInArray -NameToFind $NameToFind -List $List -Index ($index+1)} else {return $false}  }
}

function OS4RDRestart
{

<#
.SYNOPSYS

Démarrage contrôlé d'un serveur ayant le rôle Remote Desktop Services

#>

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

function OS4RDUserLogoff
{

<#
.SYNOPSYS

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
