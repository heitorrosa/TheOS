@echo off
title TheOS @heitorrosa

:: Execute the script as administrator (Not needeed, UAC already disabled)
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )

:: Checks if MinSudo exists in System and installs it if needed
if not exist "C:\Windows\System32\MinSudo.exe" (
   curl -g -k -L -# -o "C:\Windows\System32\MinSudo.exe" "https://github.com/heitorrosa/TheOS/raw/theOS/files/MinSudo.exe" >NUL 2>&1
) else (
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

call :TheOS

for /f "tokens=*" %%a in ('systeminfo ^| findstr /B /C:"OS Name"') do set OS_NAME=%%a

if "%OS_NAME%"=="OS Name:                   Microsoft Windows Server 2022 Standard" (
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

call :TheOS

for /f "delims=:{}" %%a in ('wmic path Win32_SystemEnclosure get ChassisTypes ^| findstr [0-9]') do set "CHASSIS=%%a"
set "DEVICE_TYPE=PC"
for %%a in (8 9 10 11 12 13 14 18 21 30 31 32) do if "%CHASSIS%" == "%%a" (set "DEVICE_TYPE=LAPTOP")

echo %DEVICE_TYPE% >> report.txt


:: ================================================================================================================


:ServerConfigurations
::
:: Windows Server configurations
::

:: Chocolatey Installation
set "chocodir=C:\ProgramData\chocolatey\choco.exe"
powershell Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) >> report.txt
%chocodir% feature enable -n=allowGlobalConfirmation  >> report.txt & %chocodir% feature enable -n useFipsCompliantChecksums >> report.txt & %chocodir% upgrade all >> report.txt

:: Installation of the Wireless Connectivity
%chocodir% install WirelessNetworking --source WindowsFeatures >> report.txt
reg add "HKLM\System\CurrentControlSet\Services\wlansvc" /v "Start" /t REG_DWORD /d "2" /f >> report.txt

:: Disables Password Complexity Requirements
powershell "secedit /export /cfg c:\secpol.cfg" >> report.txt
powershell -ExecutionPolicy Bypass "(gc C:\secpol.cfg).replace('PasswordComplexity = 1', 'PasswordComplexity = 0') | Out-File C:\secpol.cfg" >> report.txt
powershell "secedit /configure /db c:\windows\security\local.sdb /cfg c:\secpol.cfg /areas SECURITYPOLICY" >> report.txt
powershell rm -force c:\secpol.cfg -confirm:$false >> report.txt

:: Remove the User's Account Password
net user Administrator "" /active:yes >> report.txt

:: Uninstall Azure Arc Setup
%chocodir% uninstall AzureArcSetup --source WindowsFeatures >> report.txt

:Dependencies
::
:: Installation of required dependencies and a Web Browser
::

call :TheOS




pause & exit /b



:TheOS
cls
echo.
echo  !ESC![95m███████╗███████╗███╗   ███╗██████╗  ██████╗ ██╗   ██╗ ██████╗ ███████╗!ESC![0m
echo  ██╔════╝██╔════╝████╗ ████║██╔══██╗██╔═══██╗╚██╗ ██╔╝██╔═══██╗██╔════╝
echo  !ESC![96m█████╗  █████╗  ██╔████╔██║██████╔╝██║   ██║ ╚████╔╝ ██║   ██║███████╗!ESC![0m
echo  ██╔══╝  ██╔══╝  ██║╚██╔╝██║██╔══██╗██║   ██║  ╚██╔╝  ██║   ██║╚════██║
echo  !ESC![95m██║     ███████╗██║ ╚═╝ ██║██████╔╝╚██████╔╝   ██║   ╚██████╔╝███████║!ESC![0m
echo  !ESC![95m╚═╝     ╚══════╝╚═╝     ╚═╝╚═════╝  ╚═════╝    ╚═╝    ╚═════╝ ╚══════╝!ESC![0m
echo !ESC![95m You can get the code from this script at @heitorrosa in Github!ESC![0m
echo.
goto :eof
