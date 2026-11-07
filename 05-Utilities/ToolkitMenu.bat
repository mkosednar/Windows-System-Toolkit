@echo off
chcp 65001 >nul
setlocal
title Windows System Toolkit

:MENU
cls
echo ==========================================
echo       WINDOWS SYSTEM TOOLKIT
echo ==========================================
echo 1. Sistemske informacije
echo 2. Pregled namescenih programov
echo 3. Diagnostika baterije
echo 4. Pregled dnevnika dogodkov
echo 5. Popravilo sistema Windows
echo 6. Omrezne informacije
echo 0. Izhod
echo.
set "IZBIRA="
set /p "IZBIRA=Izberi opravilo: "

if "%IZBIRA%"=="1" (
  powershell.exe -NoProfile -File "%~dp0..\01-System-Diagnostics\SystemInfo.ps1"
  goto NAZAJ
)
if "%IZBIRA%"=="2" (
  powershell.exe -NoProfile -File "%~dp0..\01-System-Diagnostics\InstalledSoftware.ps1"
  goto NAZAJ
)
if "%IZBIRA%"=="3" (
  powershell.exe -NoProfile -File "%~dp0..\01-System-Diagnostics\BatteryHealth.ps1"
  goto NAZAJ
)
if "%IZBIRA%"=="4" (
  powershell.exe -NoProfile -File "%~dp0..\01-System-Diagnostics\EventLogReport.ps1"
  goto NAZAJ
)
if "%IZBIRA%"=="5" (
  powershell.exe -NoProfile -File "%~dp0..\02-System-Maintenance\RepairWindows.ps1"
  goto NAZAJ
)
if "%IZBIRA%"=="6" (
  powershell.exe -NoProfile -File "%~dp0..\04-Network\NetworkInfo.ps1"
  goto NAZAJ
)
if "%IZBIRA%"=="0" exit /b 0

echo Neveljavna izbira.
pause
goto MENU

:NAZAJ
echo.
pause
goto MENU
