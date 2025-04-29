# Define download paths
$downloadFolder = "$env:USERPROFILE\Downloads"
$pythonInstaller = "$downloadFolder\python-installer.exe"
$gitInstaller = "$downloadFolder\git-installer.exe"
$gitIni = "$downloadFolder\git_options.ini"
$gitInstallDir = "$env:LOCALAPPDATA\Programs\Git"
$gitBin = "$gitInstallDir\cmd"

# --- Install Python ---
$pythonExe = "python.exe"
if (-not (Get-Command $pythonExe -ErrorAction SilentlyContinue)) {
    Write-Output "Python not found. Installing..."

    $pythonUrl = "https://www.python.org/ftp/python/3.12.3/python-3.12.3-amd64.exe"

    if (-not (Test-Path $pythonInstaller)) {
        Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonInstaller
    }

    Start-Process -FilePath $pythonInstaller `
                  -ArgumentList "/quiet InstallAllUsers=0 PrependPath=1 Include_test=0" `
                  -Wait

    if (Get-Command $pythonExe -ErrorAction SilentlyContinue) {
        Write-Output "Python installed successfully."
    } else {
        Write-Warning "Python installation may have failed."
    }
} else {
    Write-Output "Python is already installed."
}

# --- Install Git ---
if (-not (Test-Path "$gitBin\git.exe")) {
    Write-Output "Git not found. Installing..."

    $gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.49.0.windows.1/Git-2.49.0-64-bit.exe"

    if (-not (Test-Path $gitInstaller)) {
        Invoke-WebRequest -Uri $gitUrl -OutFile $gitInstaller
    }

    # Write the .ini file for silent install
    @"
[Setup]
Lang=default
Dir=$gitInstallDir
Group=Git
NoIcons=1
SetupType=default
Components=gitlfs,assoc,assoc_sh,windowsterminal
Tasks=
CustomEditorPath=
DefaultBranchOption=main
PathOption=Cmd
SSHOption=OpenSSH
CURLOption=WinSSL
GitPullBehaviorOption=Merge
UseCredentialManager=Enabled
"@ | Out-File -Encoding ASCII $gitIni

    # Run installer
    Start-Process -FilePath $gitInstaller `
                  -ArgumentList "/VERYSILENT", "/NORESTART", "/LOADINF=`"$gitIni`"" `
                  -Wait

    if (Test-Path "$gitBin\git.exe") {
        Write-Output "Git installed successfully."
    } else {
        Write-Warning "Git installation may have failed."
    }

    # Add Git to PATH if not already present
    $currentUserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($currentUserPath -notlike "*$gitBin*") {
        [Environment]::SetEnvironmentVariable("PATH", "$currentUserPath;$gitBin", "User")
        Write-Output "Git added to user PATH. You may need to restart PowerShell."
    }
} else {
    Write-Output "Git is already installed."
}
