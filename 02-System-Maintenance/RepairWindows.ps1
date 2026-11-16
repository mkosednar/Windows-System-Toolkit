# Windows System Toolkit - system diagnostics and repair
# Windows 10/11 and Windows PowerShell 5.1.
# Uses built-in DISM, SFC, and CHKDSK tools. No automatic restart is performed.

$ErrorActionPreference = 'Stop'

function Test-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Administrator)) {
    Write-Host 'Administrator privileges are required for this tool.' -ForegroundColor Yellow
    Write-Host "Close this window, start PowerShell using 'Run as administrator', and run the script again."
    Read-Host 'Press Enter to exit'
    return
}

$reportDirectory = Join-Path $PSScriptRoot '..\Reports'
New-Item -ItemType Directory -Path $reportDirectory -Force | Out-Null
$logPath = Join-Path $reportDirectory ("Windows-Maintenance_{0}.log" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))

try {
    Start-Transcript -Path $logPath -Append | Out-Null
} catch {
    Write-Warning 'Could not create the log file. Continuing without session logging.'
}

function Invoke-WindowsCommand {
    param(
        [Parameter(Mandatory = $true)][string]$Program,
        [Parameter(Mandatory = $true)][string[]]$Arguments,
        [Parameter(Mandatory = $true)][string]$Description
    )

    Write-Host ''
    Write-Host ">>> $Description" -ForegroundColor Cyan
    Write-Host "$Program $($Arguments -join ' ')" -ForegroundColor DarkGray

    & $Program @Arguments
    $exitCode = $LASTEXITCODE

    if ($exitCode -eq 0) {
        Write-Host 'Command completed successfully.' -ForegroundColor Green
    } else {
        Write-Warning "Command exited with code $exitCode. Review the output and log."
    }

    return $exitCode
}

function Confirm-Repair {
    param([Parameter(Mandatory = $true)][string]$Action)
    Write-Host ''
    Write-Host "WARNING: $Action can modify Windows system files." -ForegroundColor Yellow
    return ((Read-Host 'Type YES to continue') -ceq 'YES')
}

function Invoke-DismCheck {
    [void](Invoke-WindowsCommand -Program 'DISM.exe' -Arguments @('/Online', '/Cleanup-Image', '/CheckHealth') -Description 'Quick Windows image check (DISM CheckHealth)')
}

function Invoke-DismScan {
    [void](Invoke-WindowsCommand -Program 'DISM.exe' -Arguments @('/Online', '/Cleanup-Image', '/ScanHealth') -Description 'Detailed Windows image scan (DISM ScanHealth)')
}

function Invoke-DismRepair {
    if (-not (Confirm-Repair -Action 'DISM RestoreHealth')) {
        Write-Host 'DISM repair cancelled.'
        return
    }
    [void](Invoke-WindowsCommand -Program 'DISM.exe' -Arguments @('/Online', '/Cleanup-Image', '/RestoreHealth') -Description 'Repair Windows image (DISM RestoreHealth)')
}

function Invoke-SfcRepair {
    if (-not (Confirm-Repair -Action 'SFC /scannow')) {
        Write-Host 'SFC repair cancelled.'
        return
    }
    [void](Invoke-WindowsCommand -Program 'sfc.exe' -Arguments @('/scannow') -Description 'Verify and repair protected system files (SFC)')
}

function Invoke-DiskCheck {
    $drive = (Read-Host 'Enter the drive letter to scan (e.g. C)').Trim().TrimEnd(':').ToUpperInvariant()
    if ($drive -notmatch '^[A-Z]$') {
        Write-Warning 'The input is not a valid drive letter. Disk scan skipped.'
        return
    }

    [void](Invoke-WindowsCommand -Program 'chkdsk.exe' -Arguments @("${drive}:", '/scan') -Description "Online file system scan on drive ${drive}:")
}

function Invoke-FullProcedure {
    if (-not (Confirm-Repair -Action 'the full maintenance procedure (DISM RestoreHealth and SFC may repair system files)')) {
        Write-Host 'Full maintenance procedure cancelled.'
        return
    }

    Write-Host 'Starting the recommended maintenance procedure.' -ForegroundColor Yellow
    Write-Host 'DISM may require an internet connection. This procedure may take some time.'
    Invoke-DismCheck
    Invoke-DismScan
    # Confirmation was obtained for the complete procedure above.
    [void](Invoke-WindowsCommand -Program 'DISM.exe' -Arguments @('/Online', '/Cleanup-Image', '/RestoreHealth') -Description 'Repair Windows image (DISM RestoreHealth)')
    [void](Invoke-WindowsCommand -Program 'sfc.exe' -Arguments @('/scannow') -Description 'Verify and repair protected system files (SFC)')
    Invoke-DiskCheck
    Write-Host 'Procedure finished. Review command exit codes and the log.' -ForegroundColor Green
}

function Show-Menu {
    Clear-Host
    Write-Host '===============================================' -ForegroundColor Cyan
    Write-Host '       WINDOWS SYSTEM TOOLKIT' -ForegroundColor Cyan
    Write-Host '       System diagnostics and repair'
    Write-Host '===============================================' -ForegroundColor Cyan
    Write-Host '1. Full diagnostics and repair procedure'
    Write-Host '2. Quick Windows image check (DISM)'
    Write-Host '3. Detailed Windows image scan (DISM)'
    Write-Host '4. Repair Windows image (DISM)'
    Write-Host '5. Verify and repair system files (SFC)'
    Write-Host '6. Disk check (CHKDSK)'
    Write-Host '0. Exit'
    Write-Host ''
    Write-Host "Session log: $logPath" -ForegroundColor DarkGray
}

try {
    do {
        Show-Menu
        $choice = Read-Host 'Select a task (0-6)'
        switch ($choice) {
            '1' { Invoke-FullProcedure; Read-Host 'Press Enter to continue' | Out-Null }
            '2' { Invoke-DismCheck; Read-Host 'Press Enter to continue' | Out-Null }
            '3' { Invoke-DismScan; Read-Host 'Press Enter to continue' | Out-Null }
            '4' { Invoke-DismRepair; Read-Host 'Press Enter to continue' | Out-Null }
            '5' { Invoke-SfcRepair; Read-Host 'Press Enter to continue' | Out-Null }
            '6' { Invoke-DiskCheck; Read-Host 'Press Enter to continue' | Out-Null }
            '0' { Write-Host 'Exiting the tool.' -ForegroundColor Green }
            default { Write-Warning 'Invalid selection.'; Start-Sleep -Seconds 2 }
        }
    } while ($choice -ne '0')
}
finally {
    try { Stop-Transcript | Out-Null } catch {}
    Write-Host "Log: $logPath" -ForegroundColor DarkGray
}
