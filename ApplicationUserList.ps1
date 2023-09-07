<# 

OS4 Techno, Services TI Inc.
Septembre 2023

Purpose: Get Azure Enterprise Application list with user
Repository: https://github.com/OS4Techno/OS4Tools

#>

Connect-AzureAD

Set-Location $HOME

 If (Get-Item -Path .\ApplicationUserList.csv -ErrorAction SilentlyContinue){Remove-Item .\ApplicationUserList.csv}
      
 ForEach($_ in (Get-AzureADServicePrincipal -All $true))
    {  
     Get-AzureADServiceAppRoleAssignment -ObjectId $_.objectId | 
     Select-Object ResourceDisplayName,PrincipalDisplayName, PrincipalType | 
     Export-Csv -Path .\ApplicationUserList.csv -NoTypeInformation -Append -Encoding utf8
    }

 Disconnect-AzAccount