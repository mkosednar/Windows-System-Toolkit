<#
.SYNOPSIS
    Prikaže stanje fizičnih diskov in prosti prostor logičnih pogonov.
.DESCRIPTION
    Razpoložljivost zdravstvenih podatkov je odvisna od gonilnika in strojne opreme.
#>
Write-Host '=== FIZICNI DISKI ===' -ForegroundColor Cyan
try {
    Get-PhysicalDisk -ErrorAction Stop | Select-Object FriendlyName,MediaType,HealthStatus,OperationalStatus,@{N='VelikostGB';E={[math]::Round($_.Size / 1GB,1)}} | Format-Table -AutoSize
} catch {Write-Warning "Podatkov Get-PhysicalDisk ni mogoče pridobiti: $($_.Exception.Message)"}
Write-Host "`n=== PROSTOR NA POGONIH ===" -ForegroundColor Cyan
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
    Select-Object DeviceID,VolumeName,@{N='VelikostGB';E={[math]::Round($_.Size / 1GB,1)}},@{N='ProstoGB';E={[math]::Round($_.FreeSpace / 1GB,1)}} |
    Format-Table -AutoSize
