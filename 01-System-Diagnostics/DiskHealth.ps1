<#
.SYNOPSIS
    Displays physical disk health and free space on logical drives.
.DESCRIPTION
    Availability of health data depends on the storage driver and hardware.
#>
Write-Host '=== PHYSICAL DISKS ===' -ForegroundColor Cyan
try {
    Get-PhysicalDisk -ErrorAction Stop | Select-Object FriendlyName,MediaType,HealthStatus,OperationalStatus,@{N='SizeGB';E={[math]::Round($_.Size / 1GB,1)}} | Format-Table -AutoSize
} catch {Write-Warning "Could not retrieve Get-PhysicalDisk data: $($_.Exception.Message)"}
Write-Host "`n=== DRIVE SPACE ===" -ForegroundColor Cyan
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
    Select-Object DeviceID,VolumeName,@{N='SizeGB';E={[math]::Round($_.Size / 1GB,1)}},@{N='FreeGB';E={[math]::Round($_.FreeSpace / 1GB,1)}} |
    Format-Table -AutoSize