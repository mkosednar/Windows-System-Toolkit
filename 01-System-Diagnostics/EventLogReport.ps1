# Pregled kritičnih dogodkov in napak v dnevniku System.
# Privzeto zadnjih 7 dni; dnevnikov ne spreminja.
param([ValidateRange(1,90)][int]$Dni = 7)
$ErrorActionPreference = 'Stop'
try {
 $from = (Get-Date).AddDays(-$Dni)
 $events = Get-WinEvent -FilterHashtable @{LogName='System';Level=1,2;StartTime=$from} -MaxEvents 200 -ErrorAction SilentlyContinue
 if (-not $events) { Write-Host "Dogodki niso bili najdeni." -ForegroundColor Green; return }
 $report = $events | Select-Object TimeCreated,@{N='Raven';E={if ($_.Level -eq 1) {'Kritično'} else {'Napaka'}}},ProviderName,Id,Message
 $report | Format-List
 if ((Read-Host "Shranim poročilo v CSV? (D/N)") -match '^(D|DA|Y|YES)$') {
  $dir = Join-Path $PSScriptRoot '..\Reports'; New-Item -ItemType Directory -Path $dir -Force | Out-Null
  $file = Join-Path $dir ("Napake-dnevnika_{0}.csv" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))
  $report | Export-Csv $file -NoTypeInformation -Encoding UTF8
  Write-Host "Shranjeno: $file" -ForegroundColor Green
 }
} catch { Write-Error "Napaka pri pregledu dnevnika: $($_.Exception.Message)" }
