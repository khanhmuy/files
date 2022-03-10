# General functions

$build = (Get-CimInstance Win32_OperatingSystem).version
$winver = (Get-WmiObject -class Win32_OperatingSystem).Caption
$chocoinstalled = Get-Command -Name choco.exe -ErrorAction SilentlyContinue

function setup {
    if ($winver -like "*Windows 11*") { $winver = '11' }
    elseif ($winver -like "*Windows 10*") { $winver = '10' }
}

function InstallChoco {
    if ($chocoinstalled -eq $null) {
        Write-Output "Seems like Chocolatey is not installed, installing now"
        Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        refreshenv
        choco feature enable -n allowGlobalConfirmation
    } else {
        choco feature enable -n allowGlobalConfirmation
        Write-Output "Chocolatey is already installed"
    }
}
function MSDOSMode {
    Write-Output '"MS-DOS Mode" for Windows 10 (PoC, made by Endermanch)'
    Write-Output "This is provided WITHOUT WARRANTY OF ANY KIND and is only a Proof of Concept."
    Write-Output "Big thanks to Endermanch for the scripts and his discovery of the BCPE exploit. `n`n"
    
    $conflocation = "$env:APPDATA\WindowsToolbox\"
    $windowsdos = "https://dl.malwarewatch.org/multipurpose/Windows10DOS.zip"
    
    Write-Output "Downloading files..."
    Invoke-WebRequest -Uri $windowsdos -OutFile $conflocation\Windows10DOS.zip
    
    Write-Output "Installing 7Zip4PowerShell..."
    Install-Module 7Zip4PowerShell -Scope CurrentUser -Force -Verbose
    Clear-Host
    Write-Output "Extracting..."
    Expand-7Zip -ArchiveFileName $conflocation\Windows10DOS.zip -TargetPath $conflocation -Password "mysubsarethebest" -Verbose
    
    Write-Output "Copying to System32"
    Copy-Item $conflocation\msdos.bat -Destination "C:\Windows\System32" -Force
    Copy-Item $conflocation\win.bat -Destination "C:\Windows\System32" -Force
    Copy-Item $conflocation\reboot.bat -Destination "C:\Windows\System32" -Force

    Write-Output "Removing leftovers..."
    Remove-Item -Path $conflocation\msdos.bat -Force
    Remove-Item -Path $conflocation\win.bat -Force
    Remove-Item -Path $conflocation\reboot.bat -Force
    
    Write-Output "Please use WinXEditor to add the entry to the Win+X menu (the batch file is under C:\Windows\System32\msdos.bat"
    Start-Process $conflocation\WinXEditor\WinXEditor.exe
    Write-Output "Done!"
}