Import-Module Microsoft.Graph.Authentication

Connect-MgGraph -Scopes "AuditLog.Read.All", "User.Read.All" -TenantId poshlab.xyz
.\Get-InactiveUsersByLastLogInDate.ps1 -DaysWithoutLogIn 30

Connect-MgGraph -Scopes "Reports.Read.All" -TenantId poshlab.xyz
.\Get-InactiveUsersByLastActivityDate.ps1 -DaysWithoutActivity 30
