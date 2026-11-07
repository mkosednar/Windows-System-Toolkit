<#
.SYNOPSIS
    Lists common programs configured to run at sign-in.
.DESCRIPTION
    Checks Run registry keys and Startup folders. Does not change settings.
#>
$locations = @(
    @{Name='Current user';Path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'},
    @{Name='All users';Path='HKLM:\Software\Microsoft\Windows\CurrentVersion\Run'},
    @{Name='32-bit entries';Path='HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run'}
)
$results = foreach ($location in $locations) {
    if (Test-Path $location.Path) {
        $props = Get-ItemProperty $location.Path
        foreach ($p in $props.PSObject.Properties) {
            if ($p.Name -notmatch '^PS') {
                [pscustomobject]@{Location=$location.Name;Name=$p.Name;Command=[string]$p.Value}
            }
        }
    }
}
Write-Host '=== REGISTRY STARTUP ENTRIES ===' -ForegroundColor Cyan
if ($results) {$results | Format-Table -Wrap -AutoSize} else {Write-Host 'No entries found.'}
Write-Host "`n=== STARTUP FOLDERS ===" -ForegroundColor Cyan
@([Environment]::GetFolderPath('Startup'),[Environment]::GetFolderPath('CommonStartup')) | Select-Object -Unique | ForEach-Object {
    if (Test-Path $_) {Get-ChildItem -LiteralPath $_ -Force | Select-Object Name,FullName}
}