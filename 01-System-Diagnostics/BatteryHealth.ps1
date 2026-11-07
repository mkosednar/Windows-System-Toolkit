# Diagnostika baterije prenosnega računalnika.
# Ustvari HTML poročilo Windows; sistemskih nastavitev ne spreminja.
$ErrorActionPreference = 'Stop'
try {
 $dir = Join-Path $PSScriptRoot '..\Reports'; New-Item -ItemType Directory -Path $dir -Force | Out-Null
 $file = Join-Path $dir ("Battery-Report_{0}.html" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
 $output = & powercfg.exe /batteryreport /output $file 2>&1
 if ($LASTEXITCODE -ne 0 -or -not (Test-Path $file)) { throw "Poročila ni bilo mogoče ustvariti: $output" }
 Write-Host "Poročilo ustvarjeno: $file" -ForegroundColor Green
 if ((Read-Host "Odprem poročilo? (D/N)") -match '^(D|DA|Y|YES)$') { Start-Process $file }
} catch { Write-Error "Napaka pri diagnostiki baterije: $($_.Exception.Message)" }
