<#
.SYNOPSIS
    Pregleda začasne datoteke in jih po izrecni potrditvi odstrani.
.DESCRIPTION
    Privzeto prikaže samo predogled. Za brisanje uporabite -Apply.
#>
param([switch]$Apply)
$path = $env:TEMP
if (-not (Test-Path -LiteralPath $path)) {Write-Warning "Mapa ne obstaja: $path"; return}
$files = @(Get-ChildItem -LiteralPath $path -Force -Recurse -File -ErrorAction SilentlyContinue)
$bytes = ($files | Measure-Object Length -Sum).Sum
Write-Host "Mapa: $path"
Write-Host "Datotek: $($files.Count); velikost: $([math]::Round($bytes / 1MB,2)) MB"
if (-not $Apply) {Write-Host 'Predogled: nič ni bilo izbrisano. Za izvedbo dodajte -Apply.' -ForegroundColor Yellow; return}
if ((Read-Host 'Za potrditev vpišite DA') -cne 'DA') {Write-Host 'Brisanje preklicano.'; return}
$removed=0
foreach ($file in $files) {try {Remove-Item -LiteralPath $file.FullName -Force -ErrorAction Stop; $removed++} catch {}}
Write-Host "Odstranjenih datotek: $removed od $($files.Count)." -ForegroundColor Green
