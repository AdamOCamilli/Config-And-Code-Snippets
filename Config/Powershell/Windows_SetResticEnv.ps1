<#
.SYNOPSIS
	Script to set environment variables for a restic repository on Windows for use in a Powershell session.
.DESCRIPTION
	Uses stored credentials. Must have one set up for repository where username is path to repo and password is repo password. If no credential name is provided, the script will prompt user for one instead.
.NOTES
	Author: Adam Camilli
	Date: 1/10/2022
#>

param (
    [string]$CredentialName=""
)
$Target = ""
if ($CredentialName) {
	$Target = $CredentialName
} else {
	$Target = Read-Host -Prompt "Enter name of repository (target of its credential object)"
}
try {
	# Set restic env variables with credential manager and set working dir to current user
	$TargetUserName = $(Get-StoredCredential -Target $Target).UserName
	$TargetPassword = $(Get-StoredCredential -Target $Target).GetNetworkCredential().Password
	if (-not $env:RESTIC_REPOSITORY) {
		Write-Host "Set Restic environment variables for the" $Target "repository."
	} else {
		Write-Host "Changed Restic environment variables from the" $env:CURRENT_RESTIC_TARGET "to the" $Target "repository."
	}
	$env:CURRENT_RESTIC_TARGET = $Target
	$env:RESTIC_REPOSITORY = $TargetUserName
	$env:RESTIC_PASSWORD = $TargetPassword
} catch [System.Management.Automation.RuntimeException] {
	"No repo credentials with that target name."
}

