# Reviews critical events and errors in the System event log.
# Defaults to the last 7 days; does not modify event logs.
param([ValidateRange(1,90)][int]$Days = 7)
$ErrorActionPreference = 'Stop'
try {
 $from = (Get-Date).AddDays(-$Days)
 $events = Get-WinEvent -FilterHashtable @{LogName='System';Level=1,2;StartTime=$from} -MaxEvents 200 -ErrorAction SilentlyContinue
 if (-not $events) { Write-Host "No matching events were found." -ForegroundColor Green; return }
 $report = $events | Select-Object TimeCreated,@{N='Level';E={if ($_.Level -eq 1) {'Critical'} else {'Error'}}},ProviderName,Id,Message
 $report | Format-List
 if ((Read-Host "Save the report as CSV? (Y/N)") -match '^(Y|YES)$') {
  $dir = Join-Path $PSScriptRoot '..\Reports'; New-Item -ItemType Directory -Path $dir -Force | Out-Null
  $file = Join-Path $dir ("Event-Log-Errors_{0}.csv" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
  $report | Export-Csv $file -NoTypeInformation -Encoding UTF8
  Write-Host "Saved: $file" -ForegroundColor Green
 }
} catch { Write-Error "Event log review failed: $($_.Exception.Message)" }