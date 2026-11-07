@echo off
chcp 65001 >nul
setlocal
title Windows System Toolkit

:MENU
cls
echo ==========================================
echo       WINDOWS SYSTEM TOOLKIT
echo ==========================================
echo 1. System information
echo 2. Installed applications
echo 3. Battery diagnostics
echo 4. Event log report
echo 5. Windows system repair
echo 6. Network information
echo 0. Exit
echo.
set "CHOICE="
set /p "CHOICE=Select a task: "

if "%CHOICE%"=="1" (
  powershell.exe -NoProfile -File "%~dp0..\01-System-Diagnostics\SystemInfo.ps1"
  goto BACK
)
if "%CHOICE%"=="2" (
  powershell.exe -NoProfile -File "%~dp0..\01-System-Diagnostics\InstalledSoftware.ps1"
  goto BACK
)
if "%CHOICE%"=="3" (
  powershell.exe -NoProfile -File "%~dp0..\01-System-Diagnostics\BatteryHealth.ps1"
  goto BACK
)
if "%CHOICE%"=="4" (
  powershell.exe -NoProfile -File "%~dp0..\01-System-Diagnostics\EventLogReport.ps1"
  goto BACK
)
if "%CHOICE%"=="5" (
  powershell.exe -NoProfile -File "%~dp0..\02-System-Maintenance\RepairWindows.ps1"
  goto BACK
)
if "%CHOICE%"=="6" (
  powershell.exe -NoProfile -File "%~dp0..\04-Network\NetworkInfo.ps1"
  goto BACK
)
if "%CHOICE%"=="0" exit /b 0

echo Invalid selection.
pause
goto MENU

:BACK
echo.
pause
goto MENU