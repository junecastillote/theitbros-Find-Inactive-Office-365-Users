# Get-InactiveUsersByLastLogInDate.ps1
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [int]
    $DaysWithoutLogIn
)

# Convert the date to datetimeoffset "yyyy-MM-ddThh:mm:ssZ" format.
$OnOrBefore = ((Get-Date).AddDays(-$DaysWithoutLogIn)).ToString("yyyy-MM-ddT00:00:00Z")

# Compose the API filter.
$filter = ('signInActivity/LastSignInDateTime le ' + $($OnOrBefore))

try {
    # Import the required module
    Import-Module Microsoft.Graph.Users

    # Get users and
    Get-MgUser -All -Filter $filter -ErrorAction Stop -Property `
        'DisplayName', 'UserPrincipalName', 'Mail', 'UserType', 'AccountEnabled', 'SignInActivity' |
    Select-Object 'DisplayName', 'UserPrincipalName', 'Mail', 'UserType', 'AccountEnabled',
    @{n = 'LastLoginDate'; e = {
            $(
                if (!$_.SignInActivity.LastSignInDateTime) {
                    # If no LastSignInDateTime value, set to the oldest datetime.
                    [datetime]::MinValue
                }
                else {
                    $_.SignInActivity.LastSignInDateTime
                }
            )
        }
    },
    @{n = 'DaysWithoutLogIn'; e = {
            $(
                if (!$_.SignInActivity.LastSignInDateTime) {
                    # If no LastSignInDateTime value, set it to the oldest datetime.
                    (New-TimeSpan -Start ([datetime]::MinValue)).Days
                }
                else {
                    (New-TimeSpan -Start ($_.SignInActivity.LastSignInDateTime)).Days
                }
            )
        }
    }
}
catch {
    $_.Exception.Message | Out-Default
    return $null
}