<#
.SYNOPSIS
	Script to back up folders using restic.
.DESCRIPTION
	Uses stored credentials. Must have one set up for repository you want to automate where username is path to repo and password is repo password. All stdout and stderr is redirected to log file.
.PARAMETER Credential
	The name of the credential containing restic repository path and password.
.PARAMETER Backup
	Path to backup
.PARAMETER Log
	Optional desired location of log. Located by default in parent directory of repository in file "AutomationLog.txt"
.NOTES
	To automate: 
		Create a scheduled task with desired schedule where 
			Action = "Start a program"
			Program/script = "powershell"
			Add arguments (optional) = "<path to script>\Windows_AutomateRestic.ps1 -Credential <Name of restic credential> -Backup <path to backup>"
	Author: Adam Camilli
	Date: 1/10/2022
#>

param (
	[Parameter(Mandatory, HelpMessage="Credential for repository where username is repo path, password is repo password")]
    [string]$Credential,
	
	[Parameter(Mandatory, HelpMessage="Path to back up")]
    [string]$Backup,
	
	[Parameter(HelpMessage="Optionally set location of LogFile (default is parent dir of repository)")]
	[string]$Log=""
)

$sw = [Diagnostics.Stopwatch]::StartNew()

$RepoPath = $(Get-StoredCredential -Target $Credential).UserName
$RepoPassword = $(Get-StoredCredential -Target $Credential).GetNetworkCredential().Password

if (-not $Log) {
	$Log = (Get-Item $RepoPath).parent.FullName
}
$LogFile = $Log + "\AutomationLog.txt"
("START automatic backup for {0} on {1}" -f $Credential, (Get-Date).date) | Out-File -FilePath $LogFile -Append

if (-not $env:RESTIC_REPOSITORY) {
	("Set Restic environment variables for the {0} repository." -f $Credential) | Out-File $LogFile -Append
} else {
	("Changing Restic environment variables from repo located at {0} to repo located at {1}"  -f $env:RESTIC_REPOSITORY, $Credential) | Out-File $LogFile -Append
}
"Successfully set Restic environment variables" | Out-File $LogFile -Append
$env:RESTIC_REPOSITORY = $RepoPath
$env:RESTIC_PASSWORD = $RepoPassword

# Go to backup directory in order to use relative paths for restic backup
cd $Backup

"BEGIN Restic Output: " | Out-File $LogFile -Append
restic backup --iexclude ./AppData . 1>> $LogFile 2>&1 | Out-Null # Wait for job to finish otherwise Powershell will terminate
"END Restic Output " | Out-File $LogFile -Append

ri env:RESTIC_REPOSITORY
ri env:RESTIC_PASSWORD
"Successfully unset Restic Env variables" | Out-File $LogFile -Append

$sw.Stop()
("END successful automatic backup for {0}. Total time of operation: {1}" -f $Credential, $sw.Elapsed) | Out-File $LogFile -Append

