# Generates a Windows battery report for laptop diagnostics.
# Creates an HTML report; does not change system settings.
$ErrorActionPreference = 'Stop'
try {
 $dir = Join-Path $PSScriptRoot '..\Reports'; New-Item -ItemType Directory -Path $dir -Force | Out-Null
 $file = Join-Path $dir ("Battery-Report_{0}.html" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
 $output = & powercfg.exe /batteryreport /output $file 2>&1
 if ($LASTEXITCODE -ne 0 -or -not (Test-Path $file)) { throw "Could not create the report: $output" }
 Write-Host "Report created: $file" -ForegroundColor Green
 if ((Read-Host "Open the report? (Y/N)") -match '^(Y|YES)$') { Start-Process $file }
} catch { Write-Error "Battery diagnostics failed: $($_.Exception.Message)" }