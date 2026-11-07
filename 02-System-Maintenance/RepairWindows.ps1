# Windows System Toolkit - diagnostika in popravilo sistema
# Original implementation for Windows 10/11 and Windows PowerShell 5.1.
# Uporablja vgrajena orodja DISM, SFC in CHKDSK.
# This script does not automatically restart the system.

$ErrorActionPreference = 'Stop'

function Test-Administrator {
    $identiteta = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identiteta)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Administrator)) {
    Write-Host "Administrator privileges are required for this tool." -ForegroundColor Yellow
    Write-Host "Close this window, start PowerShell using 'Run as administrator', and run the script again."
    Read-Host "Press Enter to exit"
    return
}

$mapaPorocil = Join-Path $PSScriptRoot '..\Reports'
New-Item -ItemType Directory -Path $mapaPorocil -Force | Out-Null
$potDnevnika = Join-Path $mapaPorocil ("VzdrzevanjeSistema_{0}.log" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))

try {
    Start-Transcript -Path $potDnevnika -Append | Out-Null
} catch {
    Write-Warning "Could not create the log file. Continuing without session logging."
}

function Invoke-WindowsCommand {
    param(
        [Parameter(Mandatory=$true)][string]$Program,
        [Parameter(Mandatory=$true)][string[]]$Arguments,
        [Parameter(Mandatory=$true)][string]$Description
    )

    Write-Host ""
    Write-Host ">>> $Description" -ForegroundColor Cyan
    Write-Host "$Program $($Arguments -join ' ')" -ForegroundColor DarkGray

    & $Program @Arguments
    $koda = $LASTEXITCODE

    if ($koda -eq 0) {
        Write-Host "Command completed successfully." -ForegroundColor Green
    } else {
        Write-Warning "Command exited with code $koda. Review the output and log."
    }

    return $koda
}

function Invoke-DismCheck {
    [void](Invoke-WindowsCommand -Program 'DISM.exe' -Arguments @('/Online','/Cleanup-Image','/CheckHealth') -Description 'Quick Windows image check (DISM CheckHealth)')
}

function Invoke-DismScan {
    [void](Invoke-WindowsCommand -Program 'DISM.exe' -Arguments @('/Online','/Cleanup-Image','/ScanHealth') -Description 'Detailed Windows image scan (DISM ScanHealth)')
}

function Invoke-DismRepair {
    [void](Invoke-WindowsCommand -Program 'DISM.exe' -Arguments @('/Online','/Cleanup-Image','/RestoreHealth') -Description 'Repair Windows image (DISM RestoreHealth)')
}

function Invoke-SfcRepair {
    [void](Invoke-WindowsCommand -Program 'sfc.exe' -Arguments @('/scannow') -Description 'Verify and repair protected system files (SFC)')
}

function Invoke-DiskCheck {
    $crka = Read-Host "Enter the drive letter to scan (e.g. C)"
    $crka = $crka.Trim().TrimEnd(':').ToUpperInvariant()

    if ($crka -notmatch '^[A-Z]$') {
        Write-Warning "The input is not a valid drive letter. Disk scan skipped."
        return
    }

    [void](Invoke-WindowsCommand -Program 'chkdsk.exe' -Arguments @("${crka}:",'/scan') -Description "Spletni pregled datotečnega sistema na disku ${crka}:")
}

function Invoke-FullProcedure {
    Write-Host ""
    Write-Host "Starting the recommended maintenance procedure." -ForegroundColor Yellow
    Write-Host "DISM may require an internet connection to complete."
    Write-Host "This procedure may take some time; do not close this window."

    Invoke-DismCheck
    Invoke-DismScan
    Invoke-DismRepair
    Invoke-SfcRepair
    Invoke-DiskCheck

    Write-Host ""
    Write-Host "The selected procedure is complete. Review the results above and the log." -ForegroundColor Green
}

function Show-Menu {
    Clear-Host
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "       WINDOWS SYSTEM TOOLKIT" -ForegroundColor Cyan
    Write-Host "       System diagnostics and repair"
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "1. Full diagnostics and repair procedure"
    Write-Host "2. Quick Windows image check (DISM)"
    Write-Host "3. Detailed Windows image scan (DISM)"
    Write-Host "4. Repair Windows image (DISM)"
    Write-Host "5. Pregled in popravilo sistemskih datotek (SFC)"
    Write-Host "6. Disk check (CHKDSK)"
    Write-Host "0. Izhod"
    Write-Host ""
    Write-Host "Session log: $potDnevnika" -ForegroundColor DarkGray
}

try {
    do {
        Show-Menu
        $izbira = Read-Host "Select a task (0-6)"

        switch ($izbira) {
            '1' { Invoke-FullProcedure; Read-Host "Press Enter to continue" | Out-Null }
            '2' { Invoke-DismCheck; Read-Host "Press Enter to continue" | Out-Null }
            '3' { Invoke-DismScan; Read-Host "Press Enter to continue" | Out-Null }
            '4' { Invoke-DismRepair; Read-Host "Press Enter to continue" | Out-Null }
            '5' { Invoke-SfcRepair; Read-Host "Press Enter to continue" | Out-Null }
            '6' { Invoke-DiskCheck; Read-Host "Press Enter to continue" | Out-Null }
            '0' { Write-Host "Exiting the tool." -ForegroundColor Green }
            default { Write-Warning "Invalid selection."; Start-Sleep -Seconds 2 }
        }
    } while ($izbira -ne '0')
}
finally {
    try { Stop-Transcript | Out-Null } catch {}
    Write-Host "Log: $potDnevnika" -ForegroundColor DarkGray
}
