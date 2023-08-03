# Basiaclly an automated version of WindowsToolbox, add or remove any functions that you want/don't want to use.
# It's shit but it works -me, just now.
# this thing is so janky lmao

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
Get-ChildItem -Recurse *.ps*1 | Unblock-File

Set-Location $PSScriptRoot

Clear-Host
Import-Module .\library\WinCore.psm1 -DisableNameChecking
Import-Module .\library\PrivacyFunctions.psm1 -DisableNameChecking
Import-Module .\library\Tweaks.psm1 -DisableNameChecking
Import-Module .\library\GeneralFunctions.psm1 -DisableNameChecking
Import-Module .\library\DebloatFunctions.psm1 -DisableNameChecking


setup
Write-Output "This is basically an automated version of WindowsToolbox, add or remove any functions that you want/don't want before running. You should have read the code beforehand anyway."
Write-Output "It's shit but it (barely) works -me, some 2 years ago."
Read-Host "Press enter to continue"

#Force TLS 1.2 for chocolatey support
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

#Create a system restore point
Enable-ComputerRestore -Drive "$env:SystemDrive"
Checkpoint-Computer -Description "BeforePostInstall" -RestorePointType "MODIFY_SETTINGS"

#Install chocolatey
InstallChoco

#Run functions:
   #Debloat
        Write-Output "Debloating..."
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
        DisablePrefetchPrelaunch
        DisableEdgePrelaunch
        DisableSuperfetch
        UseUTC
        ImproveSSD
        ShowExplorerFullPath
        SetExplorerThisPC
        ShowFileExtensions
        TBSingleClick
        DisableAccessibilityKeys
        SetWinXMenuCMD
        EnableVerboseStartup
        EnableClassicMenu
        Write-Output "Killing Explorer process..."
        taskkill.exe /F /IM "explorer.exe"
        Write-Output "Restarting Explorer..."
        Start-Process "explorer.exe"
        Write-Output "Waiting for explorer to complete loading"
        Start-Sleep 10
    #Install apps
        # yes im using choco because winget gets whacky on modded windows, dont @ me
        Write-Output "Installing apps..."
        choco install firefox discord zoom vscode git gh python3 microsoft-windows-terminal vlc winaero-tweaker gpg4win authy-desktop winscp 7zip spotify motrix obs ffmpeg yt-dlp -y
        refreshenv
    #Configs
        $gh = "C:\Users\$env:username\Documents\gh"
        New-Item -Path $gh -ItemType directory -Force
        Set-Location $gh

        $terminalSettings = "C:\Users\$env:username\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
        Copy-Item $PSScriptRoot\configs\terminal\settings.json -Destination $terminalSettings
        Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))
        Copy-Item $PSScriptRoot\configs\pwsh\Microsoft.PowerShell_profile.psm1 -Destination $env:USERPROFILE\Documents\WindowsPowerShell
        Copy-Item $PSScriptRoot\configs\pwsh\candy_custom.omp.json -Destination $env:USERPROFILE

        Start-Process $env:APPDATA\Spotify\Spotify.exe
        Invoke-WebRequest -useb https://raw.githubusercontent.com/spicetify/spicetify-cli/master/install.ps1 | Invoke-Expression
        Invoke-WebRequest -useb https://raw.githubusercontent.com/spicetify/spicetify-marketplace/main/resources/install.ps1 | Invoke-Expression
        refreshenv
    #Restart
        $confirm = Read-Host "Are you sure you want to restart? (y/n) Remember to save your work first."
        if($confirm -eq "y") {
            Restart-Computer
        }