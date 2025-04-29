# scripts
Coleção de scripts para uso genérico.

## Rodando no PowerShell

Execute os seguintes comandos para conseguir rodar o script no `PowerShell`:
```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/gn-mm/scripts/refs/heads/main/InstallPythonGit.ps1" -OutFile "InstallPythonGit.ps1"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\InstallPythonGit.ps1
```
