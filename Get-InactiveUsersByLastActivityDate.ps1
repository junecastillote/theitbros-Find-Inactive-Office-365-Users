#Get-InactiveUsersByLastActivityDate.ps1
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [int]
    $DaysWithoutActivity
)

try {
    Import-Module Microsoft.Graph.Reports
    $tempCsv = "$env:temp\tmp_office365users.csv"
    Get-MgReportOffice365ActiveUserDetail -Period D180 -OutFile $tempCsv -ErrorAction Stop -WarningAction SilentlyContinue
    $data = Import-Csv -Path $tempCsv
}
catch {
    $_.Exception.Message | Out-Default
    return $null
}

try {
    $data | ForEach-Object {
        [System.Collections.ArrayList]$inactiveDays = @()
        if ($_.'Has Exchange License' -eq 'TRUE') {
            if ($_.'Exchange Last Activity Date') {
                $null = $inactiveDays.Add($((New-TimeSpan -Start (Get-Date $_.'Exchange Last Activity Date')).Days))
            }
            else {
                $null = $inactiveDays.Add($((New-TimeSpan -Start (Get-Date $_.'Exchange License Assign Date')).Days))
            }
        }
        else { $null = $inactiveDays.Add(0) }

        if ($_.'Has SharePoint License' -eq 'TRUE') {
            if ($_.'SharePoint Last Activity Date') {
                $null = $inactiveDays.Add($((New-TimeSpan -Start (Get-Date $_.'SharePoint Last Activity Date')).Days))
            }
            else {
                $null = $inactiveDays.Add($((New-TimeSpan -Start (Get-Date $_.'SharePoint License Assign Date')).Days))
            }
        }
        else { $null = $inactiveDays.Add(0) }

        if ($_.'Has OneDrive License' -eq 'TRUE') {
            if ($_.'OneDrive Last Activity Date') {
                $null = $inactiveDays.Add($((New-TimeSpan -Start (Get-Date $_.'OneDrive Last Activity Date')).Days))
            }
            else {
                $null = $inactiveDays.Add($((New-TimeSpan -Start (Get-Date $_.'OneDrive License Assign Date')).Days))
            }
        }
        else { $null = $inactiveDays.Add(0) }

        if ($_.'Has Teams License' -eq 'TRUE') {
            if ($_.'Teams Last Activity Date') {
                $null = $inactiveDays.Add($((New-TimeSpan -Start (Get-Date $_.'Teams Last Activity Date')).Days))
            }
            else {
                $null = $inactiveDays.Add($((New-TimeSpan -Start (Get-Date $_.'Teams License Assign Date')).Days))
            }
        }
        else { $null = $inactiveDays.Add(0) }

        if ($_.'Has Yammer License' -eq 'TRUE') {
            if ($_.'Yammer Last Activity Date') {
                $null = $inactiveDays.Add($((New-TimeSpan -Start (Get-Date $_.'Yammer Last Activity Date')).Days))
            }
            else {
                $null = $inactiveDays.Add($((New-TimeSpan -Start (Get-Date $_.'Yammer License Assign Date')).Days))
            }
        }
        else { $null = $inactiveDays.Add(0) }

        $DaysInactive = ($inactiveDays | Sort-Object)[0]

        # $DaysInactive | Out-Default

        if ($DaysInactive -ge $DaysWithoutActivity) {
            [PSCustomObject]@{
                Name                = $_.'Display Name'
                Username            = $_.'User Principal Name'
                DaysWithoutActivity = $DaysInactive
            }
        }
    }
}
catch {
    $_.Exception.Message | Out-Default
}