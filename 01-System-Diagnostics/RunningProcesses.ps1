<#
.SYNOPSIS
    Prikaže procese z največjo porabo delovnega pomnilnika.
.PARAMETER Top
    Število procesov za prikaz (privzeto 20).
.NOTES
    Skripta samo bere podatke in ne ustavlja procesov.
#>
param([ValidateRange(1,200)][int]$Top = 20)
Get-Process -ErrorAction SilentlyContinue |
    Sort-Object WorkingSet64 -Descending |
    Select-Object -First $Top Name, Id, @{N='PomnilnikMB';E={[math]::Round($_.WorkingSet64 / 1MB, 1)}}, CPU |
    Format-Table -AutoSize
