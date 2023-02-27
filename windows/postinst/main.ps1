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
        # yes im using choco because winget gets whacky on modded windows, dont fucking @ me
        Write-Output "Installing apps..."
        choco install firefox discord zoom vscode git gh python3 microsoft-windows-terminal vlc winaero-tweaker gpg4win authy-desktop winscp 7zip nodejs spotify motrix obs ffmpeg yt-dlp nodejs-lts visualstudio2019-workload-vctools
        $temp = "$env:APPDATA\WindowsToolbox\"
        Write-Output "osu! moment"
        Invoke-WebRequest -Uri "https://m1.ppy.sh/r/osu!install.exe" -OutFile $temp\osu!install.exe
        Start-Process "$temp\osu!install.exe"

        refreshenv
    #Configs
        $gh = "C:\Users\$env:username\Documents\gh"
        New-Item -Path $gh -ItemType directory -Force
        Set-Location $gh

        $terminalSettings = "C:\Users\$env:username\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
        Copy-Item $PSScriptRoot\configs\terminal\settings.json -Destination $terminalSettings
        Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))
        Copy-Item $PSScriptRoot\configs\pwsh\Microsoft.PowerShell_profile.psm1 -Destination C:\Users\hmuy\Documents\WindowsPowerShell
        Copy-Item $PSScriptRoot\configs\pwsh\candy_custom.omp.json -Destination C:\Users\hmuy\

        Start-Process "C:\Users\hmuy\AppData\Roaming\Spotify\Spotify.exe"
        Invoke-WebRequest -useb https://raw.githubusercontent.com/spicetify/spicetify-cli/master/install.ps1 | Invoke-Expression
        Invoke-WebRequest -useb https://raw.githubusercontent.com/spicetify/spicetify-marketplace/main/resources/install.ps1 | Invoke-Expression
        refreshenv
        git clone https://github.com/catppuccin/spicetify.git $temp
        Copy-Item $temp\spicetify\catppuccin-mocha -Destination $env:APPDATA\Spicetify\Themes
        Copy-Item $temp\js\catppuccin-mocha.js -Destination $env:APPDATA\Spicetify\Extensions
        spicetify config current_theme catppuccin-mocha
        spicetify config color_scheme pink
        spicetify config inject_css 1 replace_colors 1 overwrite_assets 1
        spicetify config extensions catppuccin-mocha.js
    #Activate
        Invoke-RestMethod https://massgrave.dev/get | Invoke-Expression
    # Import ssh key(s)
        $sshPath = Read-Host "Enter the path to your ssh key(s) (leave blank if you don't have any)"
        if($sshPath -ne "") {
            $check = Test-Path $sshPath
            if ($check -eq $true) {
                Copy-Item $sshPath -Destination $env:USERPROFILE\.ssh
            } else {
                Write-Output "Path does not exist!"
            }
        } else {
            Write-Output "Skipping..."
        }
    #Restart
        $confirm = Read-Host "Are you sure you want to restart? (y/n) Remember to save your work first."
        if($confirm -eq "y") {
            Restart-Computer
        }