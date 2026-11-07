@echo off
chcp 65001 >nul
setlocal
title Quick Network Diagnostics
echo ==========================================
echo       QUICK NETWORK DIAGNOSTICS
echo ==========================================
echo.
echo Network adapter configuration:
ipconfig
echo.
echo Testing connectivity to a public IP address:
ping -n 4 1.1.1.1
echo.
echo Saving detailed information to a local report.
set "REPORTDIR=%~dp0..\..\Reports"
if not exist "%REPORTDIR%" mkdir "%REPORTDIR%"
set "REPORT=%REPORTDIR%\Network-Diagnostics_%DATE:/=-%_%TIME::=-%.txt"
set "REPORT=%REPORT: =_%"
(
 echo Quick network diagnostics - %DATE% %TIME%
 echo.
 ipconfig /all
 echo.
 route print
 echo.
) > "%REPORT%"
echo Report saved: "%REPORT%"
echo Note: ping to a public IP address may be blocked by network policy or a firewall.
pause