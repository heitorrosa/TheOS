@echo off
title FemboyOS @heitorrosa
:: Execute the script as administrator (Not needeed, UAC already disabled)
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )

powershell Set-ExecutionPolicy Unrestricted >NUL 2>&1


:Menu
@echo off
SETLOCAL EnableExtensions DisableDelayedExpansion
for /F %%a in ('echo prompt $E ^| cmd') do (
  set "ESC=%%a"
)
SETLOCAL EnableDelayedExpansion
chcp 65001 >NUL 2>&1
mode 72,21
cls
echo.
echo  !ESC![95m███████╗███████╗███╗   ███╗██████╗  ██████╗ ██╗   ██╗ ██████╗ ███████╗!ESC![0m
echo  ██╔════╝██╔════╝████╗ ████║██╔══██╗██╔═══██╗╚██╗ ██╔╝██╔═══██╗██╔════╝
echo  !ESC![96m█████╗  █████╗  ██╔████╔██║██████╔╝██║   ██║ ╚████╔╝ ██║   ██║███████╗!ESC![0m
echo  ██╔══╝  ██╔══╝  ██║╚██╔╝██║██╔══██╗██║   ██║  ╚██╔╝  ██║   ██║╚════██║
echo  !ESC![95m██║     ███████╗██║ ╚═╝ ██║██████╔╝╚██████╔╝   ██║   ╚██████╔╝███████║!ESC![0m
echo  !ESC![95m╚═╝     ╚══════╝╚═╝     ╚═╝╚═════╝  ╚═════╝    ╚═╝    ╚═════╝ ╚══════╝!ESC![0m
echo                  !ESC![95m Win32SeparationPriority Benchmarker!ESC![0m
echo.
echo.
echo.
echo.                                !ESC![95m█!ESC![0m
echo  !ESC![96m(1)!ESC![0m 14 Hex !ESC![96m(Long, Variable)!ESC![0m    !ESC![95m█!ESC![0m    !ESC![96m(3)!ESC![0m 24 Hex !ESC![96m(Short, Variable)!ESC![0m
echo.                                !ESC![95m█!ESC![0m
echo  !ESC![96m(2)!ESC![0m 18 Hex !ESC![96m(Long, Fixed)!ESC![0m       !ESC![95m█!ESC![0m    !ESC![96m(4)!ESC![0m 28 Hex !ESC![96m(Short, Fixed)!ESC![0m
echo.                                !ESC![95m█!ESC![0m
echo.                                !ESC![95m█!ESC![0m
echo. !ESC![96m(5)!ESC![0m Install CapframeX          !ESC![95m█!ESC![0m    !ESC![96m(6)!ESC![0m The best value
echo.
for /f "tokens=2,*" %%a in ('reg query HKLM\SYSTEM\ControlSet001\Control\PriorityControl /v Win32PrioritySeparation') do echo               !ESC![4mCurrent Win32PrioritySeparation!ESC![0m!ESC![96m:!ESC![0m !ESC![95m%%b!ESC![0m
set /p Menu= !ESC![96m:!ESC![0m
if %Menu%==1 goto 14Hex
if %Menu%==2 goto 18Hex
if %Menu%==3 goto 24Hex
if %Menu%==4 goto 28Hex
if %Menu%==5 goto CapframeX
if %Menu%==6 goto Bruh

:14Hex
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 20 /f > NUL 2>&1
goto Menu

:18Hex
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 24 /f > NUL 2>&1
goto Menu

:24Hex
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 36 /f > NUL 2>&1
goto Menu

:28Hex
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 40 /f > NUL 2>&1
goto Menu

:CapframeX
curl -g -k -L -# -o "%USERPROFILE%\Desktop\CapFrameX.zip" "https://cxblobs.blob.core.windows.net/releases/CapFrameX_v1.7.1_Portable.zip"
goto Menu

:Bruh
start https://tryitands.ee/
goto Menu