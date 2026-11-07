<#
.SYNOPSIS
    Prikaže podatke o procesorju, pomnilniku, BIOS-u in grafičnih vmesnikih.
.DESCRIPTION
    Uporablja vgrajene CIM razrede. Nastavitev ne spreminja.
#>
$ErrorActionPreference = 'Stop'
try {
    Write-Host "`n=== PROCESOR ===" -ForegroundColor Cyan
    Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed | Format-List
    Write-Host "`n=== POMNILNIK ===" -ForegroundColor Cyan
    Get-CimInstance Win32_PhysicalMemory | Select-Object Manufacturer, PartNumber, @{N='KapacitetaGB';E={[math]::Round($_.Capacity / 1GB, 2)}}, Speed | Format-Table -AutoSize
    Write-Host "`n=== BIOS ===" -ForegroundColor Cyan
    Get-CimInstance Win32_BIOS | Select-Object Manufacturer, SMBIOSBIOSVersion, ReleaseDate | Format-List
    Write-Host "`n=== GRAFICNI VMESNIKI ===" -ForegroundColor Cyan
    Get-CimInstance Win32_VideoController | Select-Object Name, DriverVersion | Format-Table -AutoSize
} catch {
    Write-Error "Pregled strojne opreme ni uspel: $($_.Exception.Message)"
    exit 1
}
