<#
.SYNOPSIS
    Displays the processes using the most working memory.
.PARAMETER Top
    Number of processes to display (default: 20).
.NOTES
    This script only reads process information and does not stop processes.
#>
param([ValidateRange(1,200)][int]$Top = 20)
Get-Process -ErrorAction SilentlyContinue |
    Sort-Object WorkingSet64 -Descending |
    Select-Object -First $Top Name, Id, @{N='MemoryMB';E={[math]::Round($_.WorkingSet64 / 1MB, 1)}}, CPU |
    Format-Table -AutoSize