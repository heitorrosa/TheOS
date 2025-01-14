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
:: mode 117,58 >NUL 2>&1

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

:: Activating Windows with MassGrave KMS38
powershell -Command "& ([ScriptBlock]::Create((irm https://get.activated.win))) /S /KMS38" >> report.txt

:ServerConfigurations
::
:: Windows Server configurations
::

:: Chocolatey Installation
set "chocodir=C:\ProgramData\chocolatey\choco.exe"
powershell Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')) >> report.txt
%chocodir% feature enable -n=allowGlobalConfirmation  >> report.txt
%chocodir% feature enable -n useFipsCompliantChecksums >> report.txt
%chocodir% upgrade all >> report.txt

:: Installation of the Wireless Connectivity
%chocodir% install WirelessNetworking --source WindowsFeatures >> report.txt
reg add "HKLM\System\CurrentControlSet\Services\wlansvc" /v "Start" /t REG_DWORD /d "2" /f >> report.txt

:: Enable Sound Services
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Audiosrv" /v "Start" /t REG_DWORD /d "2" /f >> report.txt
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\AudioEndpointBuilder" /v "Start" /t REG_DWORD /d "2" /f >> report.txt

:: Disables Password Complexity Requirements
powershell "secedit /export /cfg c:\secpol.cfg" >> report.txt
powershell -ExecutionPolicy Bypass "(gc C:\secpol.cfg).replace('PasswordComplexity = 1', 'PasswordComplexity = 0') | Out-File C:\secpol.cfg" >> report.txt
powershell "secedit /configure /db c:\windows\security\local.sdb /cfg c:\secpol.cfg /areas SECURITYPOLICY" >> report.txt
powershell rm -force c:\secpol.cfg -confirm:$false >> report.txt

:: Disable CAD at Lock Screen
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "DisableCAD" /t REG_DWORD /d "1" /f >NUL 2>&1

:: Remove the User's Account Password
net user Administrator "" /active:yes >> report.txt

:: Uninstall Azure Arc Setup
%chocodir% uninstall AzureArcSetup --source WindowsFeatures >> report.txt

:: Disable Server Manager at Startup
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager" /v "DoNotOpenServerManagerAtLogon" /t REG_DWORD /d "1" /f >> report.txt

:: Taskbar & Explorer QOL
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowTaskViewButton" /t REG_DWORD /d "0" /f >> report.txt

reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d "0" /f >> report.txt
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Feeds" /v "ShellFeedsTaskbarViewMode" /t REG_DWORD /d "2" /f >> report.txt

reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "EnableTransparency" /t REG_DWORD /d "0" /f >> report.txt

reg add "HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "DisableActionCenter" /t REG_DWORD /d "1" /f >> report.txt
reg add "HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "DisableNotificationCenter" /t REG_DWORD /d "1" /f >> report.txt

reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "TaskbarGlomLevel" /t REG_DWORD /d "2" /f >> report.txt

reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d "0" /f >> report.txt
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "SystemUsesLightTheme" /t REG_DWORD /d "0" /f >> report.txt

reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell\Bags\1\Desktop" /v "IconSize" /t REG_DWORD /d "32" /f >> report.txt

reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "AutoCheckSelect" /t REG_DWORD /d "1" /f >> report.txt
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Hidden" /t REG_DWORD /d "1" /f >> report.txt
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d "0" /f >> report.txt

reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "HubMode" /t REG_DWORD /d "1" /f >> report.txt

reg add "HKEY_CURRENT_USER\Keyboard Layout\Toggle" /v "Language HotKey" /t REG_DWORD /d "3" /f >> report.txt
reg add "HKEY_CURRENT_USER\Keyboard Layout\Toggle" /v "Layout HotKey" /t REG_DWORD /d "3" /f >> report.txt
reg add "HKEY_USERS\.DEFAULT\Keyboard Layout\Toggle" /v "Language HotKey" /t REG_DWORD /d "3" /f >> report.txt
reg add "HKEY_USERS\.DEFAULT\Keyboard Layout\Toggle" /v "Layout HotKey" /t REG_DWORD /d "3" /f >> report.txt

reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v "AutoEndTasks" /t REG_DWORD /d "1" /f >> report.txt

:: Changing ps1 file association with a proper PowerShell terminal
echo y | reg add "HKCR\Microsoft.PowerShellScript.1\Shell\Open\Command" /ve /t REG_SZ /d "\"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe\" -File \"%%1\" >> report.txt

:Dependencies
::
:: Installation of required dependencies and a Web Browser
::
call :TheOS

:: Installing required Visual C++ Runtimes
curl -g -k -L -# -o "C:\Windows\Temp\vcredist.exe" "https://github.com/abbodi1406/vcredist/releases/latest/download/VisualCppRedist_AIO_x86_x64.exe" >> report.txt & powershell Start-Process -FilePath "C:\Windows\Temp\vcredist.exe /aiA " >NUL 2>&1
timeout /t 5 /nobreak >NUL 2>&1

:: Installing DirectX
curl -g -k -L -# -o "C:\Windows\Temp\dxwebsetup.exe" "https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe" >> report.txt & powershell Start-Process -FilePath "C:\Windows\Temp\dxwebsetup.exe /Q" >NUL 2>&1
timeout /t 5 /nobreak >NUL 2>&1

:: Installing Thorium AVX2
curl -g -k -L -# -o "C:\Windows\Temp\ThoriumAVX2.exe" "https://github.com/Alex313031/Thorium-Win/releases/latest/download/thorium_AVX2_mini_installer.exe" >> report.txt & powershell Start-Process -FilePath "C:\Windows\Temp\ThoriumAVX2.exe /S" >NUL 2>&1
timeout /t 5 /nobreak >NUL 2>&1

:: Installing 7zip
curl -g -k -L -# -o "C:\Windows\Temp\7zip.exe" "https://www.7-zip.org/a/7z2301-x64.exe" >> report.txt & powershell Start-Process -FilePath "C:\Windows\Temp\7zip.exe /S" >NUL 2>&1
timeout /t 5 /nobreak >NUL 2>&1

:: Importing 7zip Context Menu
reg add HKCU\SOFTWARE\7-Zip\Options /v CascadeMenu /t REG_DWORD /d 0 /f >> report.txt
reg add HKCU\SOFTWARE\7-Zip\Options /v ContextMenu /t REG_DWORD /d 261 /f >> report.txt
reg add HKCU\SOFTWARE\7-Zip\Options /v CascadedMenu /t REG_DWORD /d 0 /f >> report.txt
reg add HKCU\SOFTWARE\7-Zip\Options /v MenuIcons /t REG_DWORD /d 1 /f >> report.txt
reg add HKCU\SOFTWARE\7-Zip\Options /v ElimDupExtract /t REG_DWORD /d 1 /f >> report.txt
timeout /t 5 /nobreak >NUL 2>&1

:: Installing MSI Afterburner & Inserting Basic Settings
curl -g -k -L -# -o "C:\Windows\Temp\MSI Afterburner.zip" "https://www.guru3d.com/getdownload/2c1b2414f56a6594ffef91236a87c0e976d52e0518b43f3846bab016c2f20c7c4d6ce7dfe19a0bc843da8d448bbb670058b0c9ee9a26f5cf49bc39c97da070e6eb314629af3da2d24ab0413917f73b946419b5af447da45cefb517a0840ad3003abff4f9d5fe7828bbbb910ee270b20632035fba6a450da22325b6bc5b6ecf760e598e0a09bb89139806376c01a72748cf45d6a798a241ec0787b63b8696336ce1e485eef0fbcdb6340fa3d74b142d1660f4038f9b6a10bd4d30634e03bb2790016d3b73e764a02a0e1d0633216fa76c5c1a0f8ee6671f41415a" >> report.txt
"C:\Program Files\7-Zip\7z.exe" e "C:\Windows\Temp\MSI Afterburner.zip" -oC:\Windows\Temp *.exe -r >> report.txt
"C:\Windows\Temp\MSIAfterburnerSetup466Beta3.exe" /S >> report.txt
pause & exit /b



:TheOS
cls
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.                                                                                   ▄▀▀▀█▀▀▄  ▄▀▀▄ ▄▄   ▄▀▀█▄▄▄▄      ▄▀▀▀▀▄   ▄▀▀▀▀▄ 
echo.                                                                                  █    █  ▐ █  █   ▄▀ ▐  ▄▀   ▐     █      █ █ █   ▐ 
echo.                                                                                  ▐   █     ▐  █▄▄▄█    █▄▄▄▄▄      █      █    ▀▄   
echo.                                                                                     █         █   █    █    ▌      ▀▄    ▄▀ ▀▄   █  
echo.                                                                                   ▄▀         ▄▀  ▄▀   ▄▀▄▄▄▄         ▀▀▀▀    █▀▀▀   
echo.                                                                                  █          █   █     █    ▐                 ▐      
goto :eof
