<# 

OS4 Techno, Services TI Inc.
August 2023

Purpose: Get the Teams Channels Membership with role
Repository: https://github.com/OS4Techno/OS4Tools

#>
Connect-MicrosoftTeams
$Teams = Get-Team
$Out = @{}
ForEach($G in $Teams)
    {ForEach($_ in (Get-TeamChannel -GroupId $G.GroupID))
        {$Members = ((Get-TeamChannelUser -GroupId $G.GroupID -DisplayName $_.DisplayName) | Select-Object Name,Role)
            ForEach($M in $Members)
            {
                $Out.Add($G.DisplayName+";"+$_.Displayname+";"+$M.Name+";"+$M.Role,"")
            }
        } 
    }
$Out.Keys | Set-Content -Path .\TeamsMembers.csv