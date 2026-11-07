<#
.SYNOPSIS
    Displays network adapters, IP addresses, and default gateways.
.DESCRIPTION
    Does not modify network settings.
#>
Write-Host '=== NETWORK ADAPTERS ===' -ForegroundColor Cyan
Get-NetAdapter -ErrorAction SilentlyContinue | Select-Object Name,InterfaceDescription,Status,LinkSpeed,MacAddress | Format-Table -AutoSize
Write-Host "`n=== IP ADDRESSES ===" -ForegroundColor Cyan
Get-NetIPConfiguration -ErrorAction SilentlyContinue | Select-Object InterfaceAlias,IPv4Address,IPv4DefaultGateway,DNSServer | Format-List