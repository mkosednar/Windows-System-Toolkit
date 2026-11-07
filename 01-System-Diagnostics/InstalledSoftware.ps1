# Pregled nameščenih programov
# PowerShell 5.1, Windows 10/11. Skripta samo bere register.
$ErrorActionPreference = 'Stop'
$paths = @('HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*','HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*')
try {
 $programs = foreach ($path in $paths) {
  Get-ItemProperty $path -ErrorAction SilentlyContinue | Where-Object DisplayName |
   Select-Object @{N='Ime';E={$_.DisplayName}},@{N='Različica';E={$_.DisplayVersion}},@{N='Založnik';E={$_.Publisher}},@{N='DatumNamestitve';E={$_.InstallDate}}
 }
 $programs = $programs | Sort-Object Ime -Unique
 Write-Host "Nameščeni programi: $($programs.Count)" -ForegroundColor Cyan
 $programs | Format-Table -AutoSize
 if ((Read-Host "Shranim seznam v CSV? (D/N)") -match '^(D|DA|Y|YES)$') {
  $dir = Join-Path $PSScriptRoot '..\Reports'; New-Item -ItemType Directory -Path $dir -Force | Out-Null
  $file = Join-Path $dir ("Nameščeni-programi_{0}.csv" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
  $programs | Export-Csv $file -NoTypeInformation -Encoding UTF8
  Write-Host "Shranjeno: $file" -ForegroundColor Green
 }
} catch { Write-Error "Napaka: $($_.Exception.Message)" }
