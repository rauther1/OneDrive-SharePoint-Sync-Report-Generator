<#
.SYNOPSIS
    Active Directory User Cleanup Tool

.DESCRIPTION
    Identifies inactive AD users based on last logon date,
    exports them to CSV, and optionally disables them.
#>

param (
    [int]$DaysInactive = 90,
    [string]$OutputPath = ".\InactiveUsers.csv",
    [switch]$Disable
)

Import-Module ActiveDirectory

$cutoff = (Get-Date).AddDays(-$DaysInactive)
Write-Host "Searching for users inactive since $cutoff..." -ForegroundColor Cyan

$users = Get-ADUser -Filter {LastLogonDate -lt $cutoff -and Enabled -eq $true} -Properties LastLogonDate

$users | Select-Object Name, SamAccountName, LastLogonDate |
    Export-Csv -Path $OutputPath -NoTypeInformation

if ($Disable) {
    $users | ForEach-Object { Disable-ADUser $_.SamAccountName }
    Write-Host "Inactive users disabled." -ForegroundColor Yellow
}

Write-Host "Report saved to $OutputPath" -ForegroundColor Green
