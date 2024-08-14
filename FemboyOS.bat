@echo off
title FemboyOS @heitorrosa

:: Execute the script as administrator (Not needeed, UAC already disabled)
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )

powershell Set-ExecutionPolicy Unrestricted >> report.txt

SETLOCAL EnableExtensions DisableDelayedExpansion
for /F %%a in ('echo prompt $E ^| cmd') do (
  set "ESC=%%a"
)
SETLOCAL EnableDelayedExpansion
chcp 65001 >NUL 2>&1
mode 72,12 >NUL 2>&1

:: Move the Import File
move "%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Import.bat" "C:\Windows\Temp" >> report.txt



:: ================================================================================================================



:os_checker
::
:: Windows Server 2025 & Windows Server 2022 Support Checker
::

:: Server 2025 = 11
:: Server 2022 = 10

call :FemboyOS

set OS_NAME=
set OS_VERSION=
for /f "tokens=*" %%a in ('systeminfo ^| findstr /B /C:"OS Name"') do set OS_NAME=%%a

if "%OS_NAME%"=="OS Name:                   Microsoft Windows Server 2022 Standard" (
    set OS_VERSION=10
    echo %OS_VERSION% >> report.txt
    goto device_checker

) else if "%OS_NAME%"=="OS Name:                   Microsoft Windows Server 2025 Standard" (
    set OS_VERSION=11
    echo %OS_VERSION% >> report.txt
    goto device_checker


) else (
    echo Your Windows Version is not supported
    pause
    exit /b
)



:device_checker
::
:: Device Checker (Desktop, Laptop, etc.)
:: https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/win32-systemenclosure
::

:: Destkop = D
:: Laptop = L

call :FemboyOS

set OS_CHASSIS=
for /f "delims={}" %%i in ('wmic systemenclosure get chassistypes ^| findstr "{"') do @set "OS_CHASSIS=%%i"

set "desktop=3 4 5 7 16 17 18 19 23 24"
set "laptop=9 10 6 8 12 13 14 15 20 21 22 30 31 32"

set OS_DEVICE=
for %%i in (%desktop%) do if "%OS_CHASSIS%"=="%%i" set OS_DEVICE=D >> report.txt
for %%i in (%laptop%) do if "%OS_CHASSIS%"=="%%i" set OS_DEVICE=L >> report.txt
echo %OS_DEVICE% >> report.txt



:: ================================================================================================================



:Dependencies
::
:: Installation of required dependencies and a Web Browser
::

call :FemboyOS

:: Powershell file association
powershell -ExecutionPolicy Bypass -command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/DanysysTeam/PS-SFTA/master/SFTA.ps1'));Set-FTA 'Applications\powershell.exe' '.ps1' }" >> report.txt

:: Chocolatey Installation
powershell Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) >> report.txt
choco feature enable -n allowGlobalConfirmation >> report.txt


pause



:FemboyOS
cls
echo.
echo  !ESC![95m███████╗███████╗███╗   ███╗██████╗  ██████╗ ██╗   ██╗ ██████╗ ███████╗!ESC![0m
echo  ██╔════╝██╔════╝████╗ ████║██╔══██╗██╔═══██╗╚██╗ ██╔╝██╔═══██╗██╔════╝
echo  !ESC![96m█████╗  █████╗  ██╔████╔██║██████╔╝██║   ██║ ╚████╔╝ ██║   ██║███████╗!ESC![0m
echo  ██╔══╝  ██╔══╝  ██║╚██╔╝██║██╔══██╗██║   ██║  ╚██╔╝  ██║   ██║╚════██║
echo  !ESC![95m██║     ███████╗██║ ╚═╝ ██║██████╔╝╚██████╔╝   ██║   ╚██████╔╝███████║!ESC![0m
echo  !ESC![95m╚═╝     ╚══════╝╚═╝     ╚═╝╚═════╝  ╚═════╝    ╚═╝    ╚═════╝ ╚══════╝!ESC![0m
echo !ESC![95m You can get the code from this script at @heitorrosa at Github!ESC![0m
echo.
goto :eof