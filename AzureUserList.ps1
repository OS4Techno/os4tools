<# 

OS4 Techno, Services TI Inc.
Septembre 2023

Purpose: Get information about user
Repository: https://github.com/OS4Techno/OS4Tools

#>
$Properties = "AccountEnabled,`
ID,`
createdDateTime,`
creationType,`
deletedDateTime,`
employeeHireDate, `
employeeLeaveDateTime, `
externalUserState, `
externalUserStateChangeDateTime,`
lastPasswordChangeDateTime,`
signInActivity,`
DisplayName,`
GivenName,`
JobTitle,`
UserPrincipalName,`
UserType"


$PropertiesOut = ("DisplayName",`
"AccountEnabled",`
"createdDateTime",`
"creationType",`
"deletedDateTime",`
"externalUserState", `
"externalUserStateChangeDateTime",`
"lastPasswordChangeDateTime",`
"lastSignInDateTime",`
"GivenName",`
"JobTitle",`
"UserPrincipalName",`
"UserType")

Connect-MgGraph -Scopes User.Read, User.ReadWrite, User.ReadBasic.All, User.Read.All, User.ReadWrite.All, Directory.Read.All, Directory.ReadWrite.All
Select-MgProfile beta # SignInActivity not include in the version 1.0

$UserInformation = (get-mguser -All -property $Properties  |  Select-Object -Property $PropertiesOut -ExpandProperty SignInActivity -ErrorAction SilentlyContinue | Select-Object $PropertiesOut)
$UserInformation | Export-csv -Path .\CloudUserList.CSV -Encoding utf8 -Delimiter ';'  -UseQuotes AsNeeded

Disconnect-MgGraph