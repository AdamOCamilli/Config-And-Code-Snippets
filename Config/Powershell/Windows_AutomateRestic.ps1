<#
.SYNOPSIS
	Script to back up folders using restic.
.DESCRIPTION
	Uses stored credentials. Must have one set up for repository you want to automate where username is path to repo and password is repo password. All stdout and stderr is redirected to log file.
.PARAMETER Credential
	The name of the credential containing restic repository path and password.
.PARAMETER Backup
	Path to backup
.PARAMETER Commands
	Restic commands to execute. PATHS MUST BE RELATIVE TO BACKUP PATH!
.PARAMETER LogLocation
	Optional desired location of log. Located by default in parent directory of repository
.PARAMETER LogName
	Optional desired name of log. Default name is "AutomationLog.txt"
.NOTES
	To automate: 
		Create a scheduled task with desired schedule where 
			Action = "Start a program"
			Program/script = powershell
			Add arguments = <path to script>\Windows_AutomateRestic.ps1 -Credential <Name of restic credential> -Backup <path to backup> -Commands <commands>
		Formatting arguments field for Task Scheduler using outer and inner quotes is annoying to say the least. The best way I have found to escape inner quotes for commands flag is to use single quotes as the outer quotes and escaped double quotes as the inner quotes, e.g.:
			<...> -Commands '<command> \"<arg that must be quoted>\" ; <more commands...>'
		Restic commands and their flags can thereby be ordered as necessary. 
		EXAMPLE: 
		Backup home folder (where you should probably exclude AppData folder), excluding a folder named "Unimportant Stuff", follow a forget policy, and prune unused data:
			<...> -Backup ~ <...> -Commands 'restic backup . --iexclude ./AppData/ --iexclude \"./Unimportant Stuff/\" ; restic forget -w 1; restic unlock; restic prune'
														   ^															 					 ^
														   Relative to backup path 										 					 Remove stale locks before pruning
	Author: Adam Camilli
	Date: 1/10/2022
#>

param (
	[Parameter(Mandatory, HelpMessage="Credential for repository where username is repo path, password is repo password")]
    [string]$Credential,
	
	[Parameter(Mandatory, HelpMessage="Path to back up")]
    [string]$Backup,
	
	[Parameter(Mandatory, HelpMessage="Set restic commands to execute. Separate by `";`". PATHS MUST BE RELATIVE TO BACKUP PATH!")]
	[string]$Commands,
	
	[Parameter(HelpMessage="Optionally set location of log file (default is parent dir of repository)")]
	[string]$LogLocation="",
	
	[Parameter(HelpMessage="Optionally set name of log file (default is AutomationLog.txt)")]
	[string]$LogName=""
)

# Parse a restic command for flags and verify it is a valid restic command
Function isValidResticCommand 
{
	Param([string]$Command)
	
	$rcTokenized = $Command.Trim() -split " "
	if ($rcTokenized[0] -ne "restic") { return $false }
	return $true
}

# Execute restic commands
Function executeResticCommands
{
	Param([string]$CommandStr, [string]$LogFile)
	
	$ResticCommands = $CommandStr -split ";"
	
	foreach ($resticCommand in $ResticCommands)
	{
		if (isValidResticCommand($resticCommand)) 
		{
			$sw = [Diagnostics.Stopwatch]::StartNew()
			("#" + " BEGIN COMMAND: `"{0}`" " -f $resticCommand.Trim() + "#") | Out-File -FilePath $LogFile -Append
			$OutputToLog = " 1>> {0} 2>&1" -f $LogFile
			$fullCommand = $resticCommand + $OutputToLog
			Invoke-Expression $fullCommand 
			$sw.Stop()
			("#" + "  END COMMAND. Total time of operation: {0} " -f $sw.Elapsed + "#") | Out-File -FilePath $LogFile -Append
		} 
		else 
		{
			("#" + " INVALID COMMAND: `"{0}`" " -f $resticCommand.Trim() + "#") | Out-File -FilePath $LogFile -Append
		}
	}

}

$sw = [Diagnostics.Stopwatch]::StartNew()

$RepoPath = $(Get-StoredCredential -Target $Credential).UserName
$RepoPassword = $(Get-StoredCredential -Target $Credential).GetNetworkCredential().Password

if (-not $Log) 
{
	$Log = (Get-Item $RepoPath).parent.FullName
}
$LogFile = $Log + "\TestAutomationLog.txt"
("#" * 4 + " START restic run for {0} on {1} " -f $Credential, (Get-Date) + "#" * 4) | Out-File -FilePath $LogFile -Append

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

("#" * 2 + " BEGIN Restic Run: " + "#" * 2) | Out-File $LogFile -Append
executeResticCommands -CommandStr $Commands -LogFile $LogFile | Out-Null # Wait for job to finish otherwise Powershell will terminate
#restic backup --iexclude ./AppData --iexclude ./Pictures/4chan/noice --iexclude "./Pictures/4chan/new noice" . 1>> $LogFile 2>&1 | Out-Null # Wait for job to finish otherwise Powershell will terminate
("#" * 2 + " END Restic Run. " + "#" * 2) | Out-File $LogFile -Append

ri env:RESTIC_REPOSITORY
ri env:RESTIC_PASSWORD
"Successfully unset Restic Env variables" | Out-File $LogFile -Append

$sw.Stop()
("#" * 4 + " END successful restic run for {0}. Total time of operation(s): {1} " -f $Credential, $sw.Elapsed + "#" * 4)  | Out-File $LogFile -Append

