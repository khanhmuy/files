# Basiaclly an automated version of WindowsToolbox, add or remove any functions that you want/don't want to use.
# It's shit but it works -me, just now.
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

#God fucking knows if this works
Set-ExecutionPolicy Unrestricted -Scope CurrentUser
ls -Recurse *.ps*1 | Unblock-File

Set-Location $PSScriptRoot

Clear-Host
Import-Module .\library\WinCore.psm1 -DisableNameChecking
Import-Module .\library\PrivacyFunctions.psm1 -DisableNameChecking
Import-Module .\library\Tweaks.psm1 -DisableNameChecking
Import-Module .\library\GeneralFunctions.psm1 -DisableNameChecking
Import-Module .\library\DebloatFunctions.psm1 -DisableNameChecking

#Force TLS 1.2 for chocolatey support
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

#Create a system restore point
Enable-ComputerRestore -Drive "$env:SystemDrive"
Checkpoint-Computer -Description "BeforePostInstall" -RestorePointType "MODIFY_SETTINGS"

#Install chocolatey
InstallChoco

setup
Write-Output "This is basically an automated version of WindowsToolbox, add or remove any functions that you want/don't want before running"
Write-Output "It's shit but it works -me, just now"
Read-Host "Press enter to continue"

#Run functions:
   #Debloat
        Write-Output "Debloating..."
        DisableWindowsDefender
        DisableWindowsDefenderCloud
        RemoveOneDrive
        RemoveDefaultApps
        DisableCortana
        RemoveIE
        RemoveXboxBloat
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
        choco install vlc
        choco install bitwarden
        choco install winaero-tweaker
        choco install gpg4win
        choco install authy-desktop
        choco install winscp
        choco install 7zip
        choco install nodejs
        $temp = "$env:APPDATA\WindowsToolbox\"
        $chromium = "https://github.com/Nifury/ungoogled-chromium-binaries/releases/download/102.0.5005.61/ungoogled-chromium_102.0.5005.61-1.1_installer_x64.exe"
        Write-Output "Downloading ungoogled-chromium..."
        Invoke-WebRequest -Uri $chromium -OutFile $temp\ungoogled-chromium-102.exe
        Start-Process "$temp\ungoogled-chromium-102.exe"
        MSDOSMode

        refreshenv
    #Configs
        git config --global user.name khanhmuy
        git config --global user.email maikhanhhuy0608@outlook.com
        git config --global gpg.program "C:\Program Files (x86)\GnuPG\bin\gpg.exe"
        git config --global commit.gpgsign true
        $gh = "C:\Users\$env:username\Documents\gh"
        New-Item -Path $gh -ItemType directory -Force
        Set-Location $gh
    #Restart
        $confirm = Read-Host "Are you sure you want to restart? (y/n) Remember to save your work first."
        if($confirm -eq "y") {
            Restart-Computer
        }