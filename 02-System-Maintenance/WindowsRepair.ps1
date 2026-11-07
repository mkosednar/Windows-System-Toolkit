# WindowsRepair.ps1
# Varno zaporedje diagnostike in popravil sistema Windows 10/11.
# Zahteva PowerShell 5.1 in skrbniške pravice.
# Skripta ne izvaja ponovnega zagona samodejno.

[CmdletBinding()]
param(
    [ValidateSet('Menu', 'All', 'DISM', 'SFC', 'Disk')]
    [string]$Mode = 'Menu'
)

$ErrorActionPreference = 'Continue'

function Test-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Administrator)) {
    Write-Host 'Za to orodje so potrebne skrbniške pravice.' -ForegroundColor Yellow
    Write-Host 'Zapri okno, nato zaženi PowerShell kot skrbnik in ponovi ukaz.' -ForegroundColor Yellow
    Write-Host 'Primer: .\WindowsRepair.ps1'
    exit 1
}

$reportDir = Join-Path $PSScriptRoot '..\Reports'
New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
$logFile = Join-Path $reportDir ("WindowsRepair_{0}.log" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))

try {
    Start-Transcript -Path $logFile -Force | Out-Null
} catch {
    Write-Warning "Dnevnika ni bilo mogoče ustvariti: $($_.Exception.Message)"
}

function Invoke-RepairStep {
    param(
        [Parameter(Mandatory=$true)][string]$Title,
        [Parameter(Mandatory=$true)][string]$Executable,
        [Parameter(Mandatory=$true)][string[]]$Arguments
    )

    Write-Host ''
    Write-Host ('=' * 65) -ForegroundColor DarkCyan
    Write-Host $Title -ForegroundColor Cyan
    Write-Host ('=' * 65) -ForegroundColor DarkCyan

    & $Executable @Arguments
    $code = $LASTEXITCODE

    if ($code -eq 0) {
        Write-Host 'Ukaz je zaključen.' -ForegroundColor Green
    } elseif ($code -eq 3010) {
        Write-Warning 'Postopek je zaključen; Windows priporoča ponovni zagon.'
    } else {
        Write-Warning "Ukaz je vrnil izhodno kodo $code. Preveri izpis in dnevnik."
    }
    return $code
}

function Invoke-DismRepair {
    Write-Host 'DISM preveri in po potrebi popravi Windows component store.' -ForegroundColor Gray
    Invoke-RepairStep -Title '1/3 – Popravilo slike sistema Windows (DISM)' -Executable 'DISM.exe' -Arguments @('/Online', '/Cleanup-Image', '/RestoreHealth') | Out-Null
}

function Invoke-SystemFileCheck {
    Invoke-RepairStep -Title '2/3 – Preverjanje zaščitenih sistemskih datotek (SFC)' -Executable 'sfc.exe' -Arguments @('/scannow') | Out-Null
}

function Invoke-DiskCheck {
    Invoke-RepairStep -Title '3/3 – Spletno preverjanje pogona C: (CHKDSK)' -Executable 'chkdsk.exe' -Arguments @('C:', '/scan') | Out-Null
}

try {
    do {
        if ($Mode -eq 'Menu') {
            Write-Host ''
            Write-Host 'WINDOWS – DIAGNOSTIKA IN POPRAVILA' -ForegroundColor Cyan
            Write-Host '1. Popravi komponentno shrambo Windows (DISM)'
            Write-Host '2. Preveri sistemske datoteke (SFC)'
            Write-Host '3. Preveri pogon C: (CHKDSK /scan)'
            Write-Host '4. Zaženi priporočeno zaporedje (DISM, SFC, CHKDSK)'
            Write-Host '0. Izhod'
            $choice = Read-Host 'Izberi opravilo'
        } else {
            $choice = switch ($Mode) {
                'DISM' { '1' }
                'SFC'  { '2' }
                'Disk' { '3' }
                'All'  { '4' }
            }
        }

        switch ($choice) {
            '1' { Invoke-DismRepair }
            '2' { Invoke-SystemFileCheck }
            '3' { Invoke-DiskCheck }
            '4' {
                Write-Host 'Začenjam priporočeno zaporedje popravil. Postopki lahko trajajo dlje časa.' -ForegroundColor Yellow
                Invoke-DismRepair
                Invoke-SystemFileCheck
                Invoke-DiskCheck
            }
            '0' { break }
            default {
                if ($Mode -eq 'Menu') { Write-Warning 'Neveljavna izbira.' }
            }
        }

        if ($Mode -ne 'Menu') { break }
        if ($choice -ne '0') { [void](Read-Host 'Pritisni Enter za vrnitev v meni') }
    } while ($true)
}
finally {
    try { Stop-Transcript | Out-Null } catch {}
    Write-Host ''
    Write-Host "Dnevnik izvajanja: $logFile" -ForegroundColor Green
    Write-Host 'Skripta ne zažene računalnika samodejno.' -ForegroundColor Gray
}
