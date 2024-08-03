@echo off
powershell "irm https://massgrave.dev/get | iex" >NUL 2>&1
curl -g -k -L -# -o "C:\Windows\Temp\FemboyOS.bat" "https://github.com/heitorrosa/FemboyOS/raw/femboyos/FemboyOS.bat" >NUL 2>&1
"C:\Windows\System32\minsudo.exe" --System --TrustedInstaller --Privileged "C:\Windows\Temp\FemboyOS.bat" >NUL 2>&1
