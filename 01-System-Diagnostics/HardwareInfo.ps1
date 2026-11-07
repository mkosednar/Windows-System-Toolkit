<#
.SYNOPSIS
    Displays processor, memory, BIOS, and graphics adapter information.
.DESCRIPTION
    Uses built-in CIM classes. Does not change system settings.
#>
$ErrorActionPreference = 'Stop'
try {
    Write-Host "`n=== PROCESSOR ===" -ForegroundColor Cyan
    Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed | Format-List
    Write-Host "`n=== MEMORY ===" -ForegroundColor Cyan
    Get-CimInstance Win32_PhysicalMemory | Select-Object Manufacturer, PartNumber, @{N='CapacityGB';E={[math]::Round($_.Capacity / 1GB, 2)}}, Speed | Format-Table -AutoSize
    Write-Host "`n=== BIOS ===" -ForegroundColor Cyan
    Get-CimInstance Win32_BIOS | Select-Object Manufacturer, SMBIOSBIOSVersion, ReleaseDate | Format-List
    Write-Host "`n=== GRAPHICS ADAPTERS ===" -ForegroundColor Cyan
    Get-CimInstance Win32_VideoController | Select-Object Name, DriverVersion | Format-Table -AutoSize
} catch {
    Write-Error "Hardware inspection failed: $($_.Exception.Message)"
    exit 1
}