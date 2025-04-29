# Define paths
$downloadFolder = "$env:USERPROFILE\Downloads"
$pythonInstaller = "$downloadFolder\python-installer.exe"
$gitArchive = "$downloadFolder\PortableGit.7z.exe"
$gitExtractDir = "$env:LOCALAPPDATA\Programs\PortableGit"
$gitBin = "$gitExtractDir\cmd"

# --- Install Python ---
$pythonRealCheck = "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe"
if (-not (Test-Path $pythonRealCheck)) {
    Write-Output "Python not found. Installing..."

    $pythonUrl = "https://www.python.org/ftp/python/3.12.3/python-3.12.3-amd64.exe"

    if (-not (Test-Path $pythonInstaller)) {
        Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonInstaller
    }

    Start-Process -FilePath $pythonInstaller `
                  -ArgumentList "/quiet InstallAllUsers=0 PrependPath=1 Include_test=0" `
                  -Wait

    if (Test-Path $pythonRealCheck) {
        Write-Output "Python installed successfully."
    } else {
        Write-Warning "Python installation may have failed."
    }
} else {
    Write-Output "Python is already installed."
}

# --- Install Git (Portable) ---
if (-not (Test-Path "$gitBin\git.exe")) {
    Write-Output "Portable Git not found. Installing..."

    $gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.49.0.windows.1/PortableGit-2.49.0-64-bit.7z.exe"

    if (-not (Test-Path $gitArchive)) {
        Invoke-WebRequest -Uri $gitUrl -OutFile $gitArchive
    }

    if (-not (Test-Path $gitExtractDir)) {
        New-Item -ItemType Directory -Path $gitExtractDir | Out-Null
    }

    Start-Process -FilePath $gitArchive `
                  -ArgumentList "-y -o`"$gitExtractDir`"" `
                  -Wait

    if (Test-Path "$gitBin\git.exe") {
        Write-Output "Portable Git extracted successfully."

        $currentUserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
        if ($currentUserPath -notlike "*$gitBin*") {
            [Environment]::SetEnvironmentVariable("PATH", "$currentUserPath;$gitBin", "User")
            Write-Output "Git added to user PATH. You may need to restart PowerShell."
        }
    } else {
        Write-Warning "Portable Git extraction may have failed."
    }
} else {
    Write-Output "Portable Git is already installed."
}
