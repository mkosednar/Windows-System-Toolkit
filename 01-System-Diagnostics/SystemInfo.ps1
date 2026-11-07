<#
.SYNOPSIS
    Prikaže osnovne informacije o računalniku in sistemu Windows.
.DESCRIPTION
    Prebere ime računalnika, različico sistema, čas zagona in količino pomnilnika.
.NOTES
    Skripta je pripravljena za ta projekt. Windows 10/11, PowerShell 5.1.
#>
$ErrorActionPreference = 'Stop'
try {
    $os = Get-CimInstance Win32_OperatingSystem
    $cs = Get-CimInstance Win32_ComputerSystem
    [pscustomobject]@{
        Racunalnik = $env:COMPUTERNAME
        Uporabnik = $env:USERNAME
        OperacijskiSistem = $os.Caption
        Razlicica = $os.Version
        Arhitektura = $os.OSArchitecture
        ZadnjiZagon = $os.LastBootUpTime
        PomnilnikSkupajGB = [math]::Round($cs.TotalPhysicalMemory / 1GB, 2)
        ProstiPomnilnikGB = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    } | Format-List
} catch {
    Write-Error "Pridobivanje sistemskih informacij ni uspelo: $($_.Exception.Message)"
    exit 1
}
