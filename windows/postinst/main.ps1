# Basiaclly an automated version of WindowsToolbox, add or remove any functions that you want/don't want to use.
# Self-elevate the script if required
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
if (-not $myWindowsPrincipal.IsInRole($adminRole))
   {
       # We are not running "as Administrator" - so relaunch as administrator

       # Create a new process object that starts PowerShell
       $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";

       # Specify the current script path and name as a parameter
       $newProcess.Arguments = $myInvocation.MyCommand.Definition;

       # Indicate that the process should be elevated
       $newProcess.Verb = "runas";

       # Start the new process
       [System.Diagnostics.Process]::Start($newProcess) | Out-Null

       # Exit from the current, unelevated, process
       exit
   }

Set-Location $PSScriptRoot

Import-Module .\library\Write-Menu.psm1 -DisableNameChecking
Import-Module .\library\WinCore.psm1 -DisableNameChecking
Clear-Host
Import-Module .\library\PrivacyFunctions.psm1 -DisableNameChecking
Import-Module .\library\Tweaks.psm1 -DisableNameChecking
Import-Module .\library\GeneralFunctions.psm1 -DisableNameChecking
Import-Module .\library\DebloatFunctions.psm1 -DisableNameChecking
Import-Module .\library\UndoFunctions.psm1 -DisableNameChecking

#Force TLS 1.2 for chocolatey support
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

#Create a system restore point
Enable-ComputerRestore -Drive "$env:SystemDrive"
Checkpoint-Computer -Description "BeforePostInstall" -RestorePointType "MODIFY_SETTINGS"

#Install chocolatey
InstallChoco

setup

#Functions:
   #Debloat
        Write-Output "Debloating..."
        DisableWindowsDefender
        DisableWindowsDefenderCloud
        RemoveOneDrive
    #Privacy fixes
        Write-Output "Applying privacy fixes..."
        DisableTelemetry
        PrivacyFixSettings
        DisableAppSuggestions
        DisableTailoredExperiences
        DisableAdvertisingID
        DisableActivityHistory
    #Tweaks
        Write-Output "Applying tweaks..."
        RAM 
        EnablePhotoViewer
        DisablePrefetchPrelaunch
        DisableEdgePrelaunch
        DisableSuperfetch
        UseUTC
        ImproveSSD
        RemoveThisPClutter
        ShowBuildNumberOnDesktop
        ShowExplorerFullPath
        SetExplorerThisPC
        ShowFileExtensions
        TBSingleClick
        DisableAccessibilityKeys
        SetWinXMenuCMD
        EnableVerboseStartup
        Write-Output "Restarting Explorer..."
        Write-Output "Killing Explorer process..."
        taskkill.exe /F /IM "explorer.exe"
        Write-Output "Restarting Explorer..."
        Start-Process "explorer.exe"
        Write-Output "Waiting for explorer to complete loading"
        Start-Sleep 10
    #Install apps
        Write-Output "Installing apps..."
        choco install discord
        choco install zoom
        choco install vscode
        choco install git
        choco install gh
        choco install python3
        choco install microsoft-windows-terminal
        choco install itunes
        choco install spotify
        choco install vlc
        choco install bitwarden
        choco install winaero-tweaker
        choco install gpg4win
        choco install authy-desktop
        choco install winscp
        choco install 7zip
    #Restart
        $confirm = Read-Host "Are you sure you want to restart? (y/n) Remember to save your work first"
        if($confirm -eq "y") {
            Restart-Computer
        }