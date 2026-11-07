# Lists installed applications.
# PowerShell 5.1, Windows 10/11. Reads the registry only.
$ErrorActionPreference = 'Stop'
$paths = @('HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*','HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*')
try {
 $programs = foreach ($path in $paths) {
  Get-ItemProperty $path -ErrorAction SilentlyContinue | Where-Object DisplayName |
   Select-Object @{N='Name';E={$_.DisplayName}},@{N='Version';E={$_.DisplayVersion}},@{N='Publisher';E={$_.Publisher}},@{N='InstallDate';E={$_.InstallDate}}
 }
 $programs = $programs | Sort-Object Name -Unique
 Write-Host "Installed applications: $($programs.Count)" -ForegroundColor Cyan
 $programs | Format-Table -AutoSize
 if ((Read-Host "Save the list as CSV? (Y/N)") -match '^(Y|YES)$') {
  $dir = Join-Path $PSScriptRoot '..\Reports'; New-Item -ItemType Directory -Path $dir -Force | Out-Null
  $file = Join-Path $dir ("Installed-Applications_{0}.csv" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
  $programs | Export-Csv $file -NoTypeInformation -Encoding UTF8
  Write-Host "Saved: $file" -ForegroundColor Green
 }
} catch { Write-Error "An error occurred: $($_.Exception.Message)" }