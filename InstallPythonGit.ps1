# Define os caminhos
$downloadFolder = "$env:USERPROFILE\Downloads"
$pythonInstaller = "$downloadFolder\python-installer.exe"
$gitArchive = "$downloadFolder\PortableGit.7z.exe"
$gitExtractDir = "$env:LOCALAPPDATA\Programs\PortableGit"
$gitBin = "$gitExtractDir\cmd"

# --- Instalação do Python ---
$pythonRealCheck = "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe"
if (-not (Test-Path $pythonRealCheck)) {
    Write-Output "Python nao encontrado. Iniciando instalacao..."

    $pythonUrl = "https://www.python.org/ftp/python/3.12.3/python-3.12.3-amd64.exe"

    if (-not (Test-Path $pythonInstaller)) {
        Write-Output "Baixando o instalador do Python..."
        Invoke-WebRequest -Uri $pythonUrl -OutFile $pythonInstaller
    }

    Write-Output "Executando instalador do Python..."
    Start-Process -FilePath $pythonInstaller `
                  -ArgumentList "/quiet InstallAllUsers=0 PrependPath=1 Include_test=0" `
                  -Wait

    if (Test-Path $pythonRealCheck) {
        Write-Output "Python instalado com sucesso."
    } else {
        Write-Warning "A instalacao do Python pode ter falhado."
    }
} else {
    Write-Output "Python ja esta instalado."
}

# --- Instalação do Git (versão portátil) ---
if (-not (Test-Path "$gitBin\git.exe")) {
    Write-Output "Portable Git nao encontrado. Iniciando instalacao..."

    $gitUrl = "https://github.com/git-for-windows/git/releases/download/v2.49.0.windows.1/PortableGit-2.49.0-64-bit.7z.exe"

    if (-not (Test-Path $gitArchive)) {
        Write-Output "Baixando o Portable Git..."
        Invoke-WebRequest -Uri $gitUrl -OutFile $gitArchive
    }

    if (-not (Test-Path $gitExtractDir)) {
        New-Item -ItemType Directory -Path $gitExtractDir | Out-Null
    }

    Write-Output "Extraindo o Portable Git..."
    Start-Process -FilePath $gitArchive `
                  -ArgumentList "-y -o`"$gitExtractDir`"" `
                  -Wait

    if (Test-Path "$gitBin\git.exe") {
        Write-Output "Portable Git extraido com sucesso."

        $currentUserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
        if ($currentUserPath -notlike "*$gitBin*") {
            [Environment]::SetEnvironmentVariable("PATH", "$currentUserPath;$gitBin", "User")
            Write-Output "Git adicionado a variavel PATH do usuario. Eh necessario reiniciar o PowerShell para aplicar as mudancas."
        }
    } else {
        Write-Warning "A extracao do Portable Git pode ter falhado."
    }
} else {
    Write-Output "Portable Git ja esta instalado."
}
