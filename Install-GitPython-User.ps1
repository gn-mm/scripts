<#
.SYNOPSIS
    Installs Git (Minimal) and Python for the current user (no admin required).
.DESCRIPTION
    Downloads and installs:
    1. Git for Windows (Minimal/Portable)
    2. Latest Python (User-install mode)
    Both are added to the user's PATH.
.NOTES
    File Name      : Install-GitPython-User.ps1
    Author         : Your Name
    Prerequisite   : PowerShell 5.1+
#>

# Function to check if a command exists
function Test-CommandExists {
    param($command)
    try { return (Get-Command $command -ErrorAction Stop) -ne $null }
    catch { return $false }
}

# Function to add to USER PATH if not present
function Add-ToUserPath {
    param([string]$pathToAdd)
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    if ($userPath -split ';' -notcontains $pathToAdd) {
        $newPath = if ($userPath) { "$userPath;$pathToAdd" } else { $pathToAdd }
        [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
        Write-Host "Added to user PATH: $pathToAdd" -ForegroundColor Green
    }
}

# Create a temp directory for downloads
$tempDir = Join-Path $env:TEMP "GitPythonInstall"
if (-not (Test-Path $tempDir)) { New-Item -ItemType Directory -Path $tempDir | Out-Null }

# --- 1. Install Git (Minimal/Portable) ---
if (Test-CommandExists "git") {
    Write-Host "[✓] Git already installed: $(git --version)" -ForegroundColor Green
} else {
    Write-Host "Downloading Git (Minimal)..." -ForegroundColor Yellow
    $gitUrl = "https://github.com/git-for-windows/git/releases/latest/download/MinGit-64-bit.zip"
    $gitZip = Join-Path $tempDir "MinGit.zip"
    Invoke-WebRequest -Uri $gitUrl -OutFile $gitZip -UseBasicParsing

    # Extract to user's local AppData
    $gitInstallDir = Join-Path $env:LOCALAPPDATA "Git"
    if (-not (Test-Path $gitInstallDir)) { New-Item -ItemType Directory -Path $gitInstallDir | Out-Null }
    Expand-Archive -Path $gitZip -DestinationPath $gitInstallDir -Force

    # Add Git to user PATH
    $gitCmdPath = Join-Path $gitInstallDir "cmd"
    Add-ToUserPath $gitCmdPath
    Write-Host "[✓] Git installed (portable)" -ForegroundColor Green
}

# --- 2. Install Python (User Mode) ---
if (Test-CommandExists "python") {
    Write-Host "[✓] Python already installed: $(python --version)" -ForegroundColor Green
} else {
    Write-Host "Finding latest Python..." -ForegroundColor Yellow
    $pythonUrl = "https://www.python.org/ftp/python/latest/python-3.x-amd64.exe"

    # Fallback if latest detection fails
    try {
        $releasesPage = (Invoke-WebRequest -Uri "https://www.python.org/downloads/windows/" -UseBasicParsing).Content
        $latestStable = [regex]::Match($releasesPage, 'href="(/ftp/python/.*?/python-.*?-amd64\.exe)"').Groups[1].Value
        if ($latestStable) { $pythonUrl = "https://www.python.org$latestStable" }
    } catch {
        Write-Warning "Using fallback Python URL"
        $pythonUrl = "https://www.python.org/ftp/python/3.12.0/python-3.12.0-amd64.exe"
    }

    $pythonInstaller = Join-Path $tempDir "python-setup.exe"
    Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonInstaller -UseBasicParsing

    Write-Host "Installing Python (user mode)..." -ForegroundColor Yellow
    # Flags: Install just for this user, add to PATH, no admin
    $installArgs = "/quiet", "InstallLauncherAllUsers=0", "Include_launcher=0", "PrependPath=1", "AssociateFiles=0", "Shortcuts=0"
    Start-Process -FilePath $pythonInstaller -ArgumentList $installArgs -Wait

    Write-Host "[✓] Python installed (user mode)" -ForegroundColor Green
}

# --- Cleanup & Refresh PATH ---
Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Done! Restart your terminal for PATH changes to apply." -ForegroundColor Cyan
