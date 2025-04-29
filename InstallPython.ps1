Invoke-WebRequest -Uri "https://www.python.org/ftp/python/3.12.3/python-3.12.3-amd64.exe" `
                  -OutFile "$env:USERPROFILE\Downloads\python-installer.exe"

Start-Process -FilePath "$env:USERPROFILE\Downloads\python-installer.exe" `
              -ArgumentList "/quiet InstallAllUsers=0 PrependPath=1 Include_test=0" `
              -Wait
