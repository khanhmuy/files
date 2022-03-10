powershell -command "Set-ExecutionPolicy Unrestricted -Scope CurrentUser"
powershell -command "ls -Recurse *.ps*1 | Unblock-File"
powershell "& ""./main.ps1"""