<#
.SYNOPSIS
    Izpiše običajne vnose programov, ki se zaženejo ob prijavi.
.DESCRIPTION
    Pregleda registrske ključe Run in zagonske mape. Nastavitev ne spreminja.
#>
$locations = @(
    @{Ime='Trenutni uporabnik';Pot='HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'},
    @{Ime='Vsi uporabniki';Pot='HKLM:\Software\Microsoft\Windows\CurrentVersion\Run'},
    @{Ime='32-bitni vnosi';Pot='HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run'}
)
$results = foreach ($location in $locations) {
    if (Test-Path $location.Pot) {
        $props = Get-ItemProperty $location.Pot
        foreach ($p in $props.PSObject.Properties) {
            if ($p.Name -notmatch '^PS') {
                [pscustomobject]@{Lokacija=$location.Ime;Ime=$p.Name;Ukaz=[string]$p.Value}
            }
        }
    }
}
Write-Host '=== VNOSI V REGISTRU ===' -ForegroundColor Cyan
if ($results) {$results | Format-Table -Wrap -AutoSize} else {Write-Host 'Ni najdenih vnosov.'}
Write-Host "`n=== ZAGONSKI MAPI ===" -ForegroundColor Cyan
@([Environment]::GetFolderPath('Startup'),[Environment]::GetFolderPath('CommonStartup')) | Select-Object -Unique | ForEach-Object {
    if (Test-Path $_) {Get-ChildItem -LiteralPath $_ -Force | Select-Object Name,FullName}
}
