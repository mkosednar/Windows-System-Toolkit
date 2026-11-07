<#
.SYNOPSIS
    Prikaže omrežne vmesnike, IP-naslove in privzete prehode.
.DESCRIPTION
    Skripta ne spreminja omrežnih nastavitev.
#>
Write-Host '=== OMREZNI VMESNIKI ===' -ForegroundColor Cyan
Get-NetAdapter -ErrorAction SilentlyContinue | Select-Object Name,InterfaceDescription,Status,LinkSpeed,MacAddress | Format-Table -AutoSize
Write-Host "`n=== IP-NASLOVI ===" -ForegroundColor Cyan
Get-NetIPConfiguration -ErrorAction SilentlyContinue | Select-Object InterfaceAlias,IPv4Address,IPv4DefaultGateway,DNSServer | Format-List
