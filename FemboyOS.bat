@echo off
title FemboyOS @heitorrosa

:: Execute the script as administrator (Not needeed, UAC already disabled)
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )

:: Checks if you are running the script at SYSTEM privileges and install MinSudo if needed
for /f "tokens=*" %%a in ('whoami') do set PRIVILEGES=%%a

if "%PRIVILEGES%"=="nt authority\system" (
   goto script

) else (
    :: curl -g -k -L -# -o "C:\Windows\System32\MinSudo.exe" "https://github.com/heitorrosa/FemboyOS/raw/femboyos/files/MinSudo.exe" >NUL 2>&1 & C:\Windows\System32\MinSudo.exe /S /TI /P %~dpnx0 >NUL 2>&1
    goto script
)

:script

powershell Set-ExecutionPolicy Unrestricted >> report.txt

SETLOCAL EnableExtensions DisableDelayedExpansion
for /F %%a in ('echo prompt $E ^| cmd') do (
  set "ESC=%%a"
)
SETLOCAL EnableDelayedExpansion
chcp 65001 >NUL 2>&1
mode 72,12 >NUL 2>&1

:: ================================================================================================================



:os_checker
::
:: Windows Server 2025 & Windows Server 2022 Support Checker
::

:: Server 2025 = S25
:: Server 2022 = S22

call :FemboyOS

for /f "tokens=*" %%a in ('systeminfo ^| findstr /B /C:"OS Name"') do set OS_NAME=%%a

if "%OS_NAME%"=="OS Name:                   Microsoft Windows Server 2022 Standard" (
    set OS_VERSION=S22 & echo S22 >> report.txt
    goto device_checker

) else if "%OS_NAME%"=="OS Name:                   Microsoft Windows Server 2025 Standard" (
    set OS_VERSION=S25 & echo S25 >> report.txt
    goto device_checker


) else (
    echo Your Windows Version is not supported
    pause & exit /b
)



:device_checker
::
:: Device Checker (Desktop, Laptop, etc.)
:: https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/win32-systemenclosure
::

:: LAPTOP
:: PC

call :FemboyOS

for /f "delims=:{}" %%a in ('wmic path Win32_SystemEnclosure get ChassisTypes ^| findstr [0-9]') do set "CHASSIS=%%a"
set "DEVICE_TYPE=PC"
for %%a in (8 9 10 11 12 13 14 18 21 30 31 32) do if "%CHASSIS%" == "%%a" (set "DEVICE_TYPE=LAPTOP")

echo %DEVICE_TYPE% >> report.txt


:: ================================================================================================================


:ServerConfigurations
::
:: Windows Server configurations
::

:: Adds a RunOnce Registry for continuing the script
echo y | reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v FemboyOS /t REG_SZ /d "%~dpnx0" >> report.txt & echo y >> report.txt

:: Installation of the Wireless Connectivity
powershell Install-WindowsFeature -Name Wireless-Networking >> report.txt
reg add "HKLM\System\CurrentControlSet\Services\wlansvc" /v "Start" /t REG_DWORD /d "2" /f >> report.txt

:: Disables Password Complexity Requirements
powershell "secedit /export /cfg c:\secpol.cfg" >> report.txt
powershell -ExecutionPolicy Bypass "(gc C:\secpol.cfg).replace('PasswordComplexity = 1', 'PasswordComplexity = 0') | Out-File C:\secpol.cfg" >> report.txt
powershell "secedit /configure /db c:\windows\security\local.sdb /cfg c:\secpol.cfg /areas SECURITYPOLICY" >> report.txt
powershell rm -force c:\secpol.cfg -confirm:$false >> report.txt

:: Remove the User's Account Password
net user Administrator "" /active:yes >> report.txt

:: Install Powershell Windows Update Service and Run Updates
powershell Install-Module PSWindowsUpdate -Force >> report.txt
powershell Install-WindowsUpdate -MicrosoftUpdate -AcceptAll -AutoReboot >> report.txt

:: Remove the RunOnce entry from the System if needed
echo y | reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v FemboyOS >> report.txt

:: Uninstall Azure Arc Setup
powershell Uninstall-WindowsFeature -Name AzureArcSetup >> report.txt

:Dependencies
::
:: Installation of required dependencies and a Web Browser
::

call :FemboyOS

:: Chocolatey Installation
powershell Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) >> report.txt


pause & exit /b



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
