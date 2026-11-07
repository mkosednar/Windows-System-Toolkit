<#
.SYNOPSIS
    Displays basic information about the computer and Windows operating system.
.DESCRIPTION
    Reads the computer name, operating system version, boot time, and memory information.
.NOTES
    Created for this project. Windows 10/11, PowerShell 5.1.
#>
$ErrorActionPreference = 'Stop'
try {
    $os = Get-CimInstance Win32_OperatingSystem
    $cs = Get-CimInstance Win32_ComputerSystem
    [pscustomobject]@{
        Computer = $env:COMPUTERNAME
        User = $env:USERNAME
        OperatingSystem = $os.Caption
        Version = $os.Version
        Architecture = $os.OSArchitecture
        LastBoot = $os.LastBootUpTime
        TotalMemoryGB = [math]::Round($cs.TotalPhysicalMemory / 1GB, 2)
        FreeMemoryGB = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    } | Format-List
} catch {
    Write-Error "Failed to retrieve system information: $($_.Exception.Message)"
    exit 1
}