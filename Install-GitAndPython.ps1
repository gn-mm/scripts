<#
.SYNOPSIS
    Downloads and installs Git for Windows (command line version) and Python automatically.
.DESCRIPTION
    This script will:
    1. Download the latest Git for Windows (Minimal/command line version)
    2. Install Git silently
    3. Download the latest stable Python release
    4. Install Python with common options silently
    5. Add Python and Git to system PATH if not already present
.NOTES
    File Name      : Install-GitAndPython.ps1
    Author         : Your Name
    Prerequisite   : PowerShell 5.1 or later
    Run as Administrator: Recommended
#>

#Requires -RunAsAdministrator

# Function to check if a command exists
function Test-CommandExists {
    param($command)
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'stop'
    try {
        if(Get-Command $command){
            return $true
        }
    } Catch {
        return $false
    } Finally {
        $ErrorActionPreference=$oldPreference
    }
}

# Function to add to PATH if not already present
function Add-ToPath {
    param(
        [string]$pathToAdd
    )
    
    $currentPath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    if ($currentPath -split ';' -notcontains $pathToAdd) {
        $newPath = $currentPath + ';' + $pathToAdd
        [Environment]::SetEnvironmentVariable('Path', $newPath, 'Machine')
        Write-Host "Added $pathToAdd to system PATH"
    } else {
        Write-Host "$pathToAdd is already in PATH"
    }
}

# Temporary directory for downloads
$tempDir = Join-Path -Path $env:TEMP -ChildPath "GitPythonInstall"
if (-not (Test-Path -Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir | Out-Null
}

# 1. Install Git for Windows (Minimal/command line version)
Write-Host "Checking/Installing Git for Windows..." -ForegroundColor Cyan

if (Test-CommandExists -command "git") {
    Write-Host "Git is already installed. Version: $(git --version)" -ForegroundColor Green
} else {
    # Get latest Git for Windows portable (minimal) version
    $gitUrl = "https://github.com/git-for-windows/git/releases/latest/download/MinGit-64-bit.zip"
    $gitZip = Join-Path -Path $tempDir -ChildPath "MinGit.zip"
    
    Write-Host "Downloading Git for Windows..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $gitUrl -OutFile $gitZip
    
    Write-Host "Extracting Git..." -ForegroundColor Yellow
    Expand-Archive -Path $gitZip -DestinationPath "$env:ProgramFiles\Git" -Force
    
    # Add Git to system PATH
    Add-ToPath -pathToAdd "$env:ProgramFiles\Git\cmd"
    
    Write-Host "Git installed successfully!" -ForegroundColor Green
}

# 2. Install Python
Write-Host "Checking/Installing Python..." -ForegroundColor Cyan

if (Test-CommandExists -command "python") {
    Write-Host "Python is already installed. Version: $(python --version)" -ForegroundColor Green
} else {
    # Get latest stable Python version
    $pythonUrl = "https://www.python.org/ftp/python/latest/python-3.x-amd64.exe"
    
    # Find the actual latest version
    try {
        $releasesUrl = "https://www.python.org/downloads/windows/"
        $releasesPage = Invoke-WebRequest -Uri $releasesUrl -UseBasicParsing
        $latestStable = ($releasesPage.Links | Where-Object { $_.href -match 'python-3\.\d+\.\d+-amd64\.exe' } | Select-Object -First 1).href
        $pythonUrl = "https://www.python.org$latestStable"
    } catch {
        Write-Warning "Could not determine latest Python version. Using fallback URL."
        $pythonUrl = "https://www.python.org/ftp/python/3.11.4/python-3.11.4-amd64.exe"
    }
    
    $pythonInstaller = Join-Path -Path $tempDir -ChildPath "python-installer.exe"
    
    Write-Host "Downloading Python..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonInstaller
    
    Write-Host "Installing Python..." -ForegroundColor Yellow
    # Install Python with common options:
    # - Install for all users
    # - Add Python to PATH
    # - Precompile standard library
    $installArgs = "/quiet", "InstallAllUsers=1", "PrependPath=1", "CompileAll=1"
    Start-Process -FilePath $pythonInstaller -ArgumentList $installArgs -Wait
    
    Write-Host "Python installed successfully!" -ForegroundColor Green
    
    # Refresh PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

# Clean up
Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Installation completed successfully!" -ForegroundColor Green
Write-Host "You may need to restart your terminal or computer for PATH changes to take effect." -ForegroundColor Yellow
