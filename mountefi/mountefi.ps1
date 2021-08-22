# Mount EFI partition on Windows, then download and use Explorer++ to access the partition (dw it's safe)

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

Write-Output "This script will automatically mount the EFI partition, then download and launch Explorer++ to access the partition"
Read-Host "Press Enter to continue"
$seldisk = Read-Host "Select the disk you want to mount the EFI partition (usually 0)"
$selpart = Read-Host "Select the EFI partition (usually 1)"
$selletter = Read-Host "Select the mount letter"
$disk = "disk $seldisk"
$part = "part $selpart"
$letter = "letter=$selletter"
$explorerpp = "https://explorerplusplus.com/software/explorer++_1.3.5_x64.zip"

((Get-Content -Path $PSScriptRoot\mountefi.txt -Raw) -replace 'disk',$disk) | Set-Content -Path $PSScriptRoot\mountefi.txt
((Get-Content -Path $PSScriptRoot\mountefi.txt -Raw) -replace 'part',$part) | Set-Content -Path $PSScriptRoot\mountefi.txt 
((Get-Content -Path $PSScriptRoot\mountefi.txt -Raw) -replace 'letter=',$letter) | Set-Content -Path $PSScriptRoot\mountefi.txt 
diskpart.exe /s $PSScriptRoot\mountefi.txt

((Get-Content -Path $PSScriptRoot\mountefi.txt -Raw) -replace $disk,'disk') | Set-Content -Path $PSScriptRoot\mountefi.txt
((Get-Content -Path $PSScriptRoot\mountefi.txt -Raw) -replace $part,'part') | Set-Content -Path $PSScriptRoot\mountefi.txt 
((Get-Content -Path $PSScriptRoot\mountefi.txt -Raw) -replace $letter,'letter=') | Set-Content -Path $PSScriptRoot\mountefi.txt

Write-Output "Downloading Explorer++.."
Invoke-WebRequest -Uri $explorerpp -OutFile $PSScriptRoot\explorer++_1.3.5_x64.zip
Write-Output "Extracting..."
Expand-Archive -LiteralPath "$PSScriptRoot\explorer++_1.3.5_x64.zip" -DestinationPath $PSScriptRoot\explorer++_1.3.5_x64
Start-Process $PSScriptRoot\explorer++_1.3.5_x64\Explorer++.exe
Write-Output "Exitting"