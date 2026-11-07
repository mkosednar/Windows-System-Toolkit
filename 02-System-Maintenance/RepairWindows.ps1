# Windows System Toolkit - diagnostika in popravilo sistema
# Avtorska izvedba za Windows 10/11 in Windows PowerShell 5.1.
# Uporablja vgrajena orodja DISM, SFC in CHKDSK.
# Skripta ne izvaja samodejnega ponovnega zagona sistema.

$ErrorActionPreference = 'Stop'

function Test-Skrbnik {
    $identiteta = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identiteta)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Skrbnik)) {
    Write-Host "Za to orodje so potrebne skrbniške pravice." -ForegroundColor Yellow
    Write-Host "Zapri okno, nato PowerShell zaženi z možnostjo 'Zaženi kot skrbnik' in ponovno zaženi skripto."
    Read-Host "Pritisni Enter za izhod"
    return
}

$mapaPorocil = Join-Path $PSScriptRoot '..\Reports'
New-Item -ItemType Directory -Path $mapaPorocil -Force | Out-Null
$potDnevnika = Join-Path $mapaPorocil ("VzdrzevanjeSistema_{0}.log" -f (Get-Date -Format 'yyyyMMdd_HHmmss'))

try {
    Start-Transcript -Path $potDnevnika -Append | Out-Null
} catch {
    Write-Warning "Dnevnika ni bilo mogoče ustvariti. Nadaljujem brez snemanja seje."
}

function Invoke-UkazWindows {
    param(
        [Parameter(Mandatory=$true)][string]$Program,
        [Parameter(Mandatory=$true)][string[]]$Argumenti,
        [Parameter(Mandatory=$true)][string]$Opis
    )

    Write-Host ""
    Write-Host ">>> $Opis" -ForegroundColor Cyan
    Write-Host "$Program $($Argumenti -join ' ')" -ForegroundColor DarkGray

    & $Program @Argumenti
    $koda = $LASTEXITCODE

    if ($koda -eq 0) {
        Write-Host "Ukaz je uspešno zaključen." -ForegroundColor Green
    } else {
        Write-Warning "Ukaz se je zaključil s kodo $koda. Preveri izpis in dnevnik."
    }

    return $koda
}

function Invoke-DismPregled {
    [void](Invoke-UkazWindows -Program 'DISM.exe' -Argumenti @('/Online','/Cleanup-Image','/CheckHealth') -Opis 'Hiter pregled Windows slike (DISM CheckHealth)')
}

function Invoke-DismPoglobljeno {
    [void](Invoke-UkazWindows -Program 'DISM.exe' -Argumenti @('/Online','/Cleanup-Image','/ScanHealth') -Opis 'Poglobljen pregled Windows slike (DISM ScanHealth)')
}

function Invoke-DismPopravilo {
    [void](Invoke-UkazWindows -Program 'DISM.exe' -Argumenti @('/Online','/Cleanup-Image','/RestoreHealth') -Opis 'Popravilo Windows slike (DISM RestoreHealth)')
}

function Invoke-SfcPopravilo {
    [void](Invoke-UkazWindows -Program 'sfc.exe' -Argumenti @('/scannow') -Opis 'Preverjanje in popravilo zaščitenih sistemskih datotek (SFC)')
}

function Invoke-PregledDiska {
    $crka = Read-Host "Vnesi črko diska za pregled (npr. C)"
    $crka = $crka.Trim().TrimEnd(':').ToUpperInvariant()

    if ($crka -notmatch '^[A-Z]$') {
        Write-Warning "Vnos ni veljavna črka pogona. Pregled diska je preskočen."
        return
    }

    [void](Invoke-UkazWindows -Program 'chkdsk.exe' -Argumenti @("${crka}:",'/scan') -Opis "Spletni pregled datotečnega sistema na disku ${crka}:")
}

function Invoke-CelotenPostopek {
    Write-Host ""
    Write-Host "Začenjam priporočeni postopek vzdrževanja." -ForegroundColor Yellow
    Write-Host "DISM lahko za dokončanje potrebuje internetno povezavo."
    Write-Host "Postopek lahko traja precej časa; okna ne zapiraj."

    Invoke-DismPregled
    Invoke-DismPoglobljeno
    Invoke-DismPopravilo
    Invoke-SfcPopravilo
    Invoke-PregledDiska

    Write-Host ""
    Write-Host "Izbrani postopek je končan. Preglej rezultate zgoraj in dnevnik." -ForegroundColor Green
}

function Show-Meni {
    Clear-Host
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "       WINDOWS SYSTEM TOOLKIT" -ForegroundColor Cyan
    Write-Host "       Diagnostika in popravilo sistema"
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "1. Celoten postopek diagnostike in popravila"
    Write-Host "2. Hiter pregled Windows slike (DISM)"
    Write-Host "3. Poglobljen pregled Windows slike (DISM)"
    Write-Host "4. Popravilo Windows slike (DISM)"
    Write-Host "5. Pregled in popravilo sistemskih datotek (SFC)"
    Write-Host "6. Pregled diska (CHKDSK)"
    Write-Host "0. Izhod"
    Write-Host ""
    Write-Host "Dnevnik seje: $potDnevnika" -ForegroundColor DarkGray
}

try {
    do {
        Show-Meni
        $izbira = Read-Host "Izberi opravilo (0-6)"

        switch ($izbira) {
            '1' { Invoke-CelotenPostopek; Read-Host "Pritisni Enter za nadaljevanje" | Out-Null }
            '2' { Invoke-DismPregled; Read-Host "Pritisni Enter za nadaljevanje" | Out-Null }
            '3' { Invoke-DismPoglobljeno; Read-Host "Pritisni Enter za nadaljevanje" | Out-Null }
            '4' { Invoke-DismPopravilo; Read-Host "Pritisni Enter za nadaljevanje" | Out-Null }
            '5' { Invoke-SfcPopravilo; Read-Host "Pritisni Enter za nadaljevanje" | Out-Null }
            '6' { Invoke-PregledDiska; Read-Host "Pritisni Enter za nadaljevanje" | Out-Null }
            '0' { Write-Host "Zaključujem orodje." -ForegroundColor Green }
            default { Write-Warning "Neveljavna izbira."; Start-Sleep -Seconds 2 }
        }
    } while ($izbira -ne '0')
}
finally {
    try { Stop-Transcript | Out-Null } catch {}
    Write-Host "Dnevnik: $potDnevnika" -ForegroundColor DarkGray
}
