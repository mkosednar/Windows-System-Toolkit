@echo off
chcp 65001 >nul
setlocal
title Hitra omrežna diagnostika
echo ==========================================
echo       HITRA OMREŽNA DIAGNOSTIKA
echo ==========================================
echo.
echo Konfiguracija omrežnih vmesnikov:
ipconfig
echo.
echo Preverjanje povezave z javnim naslovom:
ping -n 4 1.1.1.1
echo.
echo Podrobne informacije shranim v lokalno poročilo.
set "REPORTDIR=%~dp0..\..\Reports"
if not exist "%REPORTDIR%" mkdir "%REPORTDIR%"
set "REPORT=%REPORTDIR%\Omrezna-diagnostika_%DATE:/=-%_%TIME::=-%.txt"
set "REPORT=%REPORT: =_%"
(
 echo Hitra omrezna diagnostika - %DATE% %TIME%
 echo.
 ipconfig /all
 echo.
 route print
 echo.
) > "%REPORT%"
echo Poročilo shranjeno: "%REPORT%"
echo Opomba: ping na javni naslov lahko blokira omrežni pravilnik ali požarni zid.
pause
