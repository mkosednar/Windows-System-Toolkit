<#
.SYNOPSIS
    Previews temporary files and removes them only after explicit confirmation.
.DESCRIPTION
    Preview mode is the default. Use -Apply to enable deletion.
#>
param([switch]$Apply)
$path = $env:TEMP
if (-not (Test-Path -LiteralPath $path)) {Write-Warning "Directory does not exist: $path"; return}
$files = @(Get-ChildItem -LiteralPath $path -Force -Recurse -File -ErrorAction SilentlyContinue)
$bytes = ($files | Measure-Object Length -Sum).Sum
Write-Host "Directory: $path"
Write-Host "Files: $($files.Count); size: $([math]::Round($bytes / 1MB,2)) MB"
if (-not $Apply) {Write-Host 'Preview only: no files were deleted. Add -Apply to proceed.' -ForegroundColor Yellow; return}
if ((Read-Host 'Type YES to confirm') -cne 'YES') {Write-Host 'Deletion cancelled.'; return}
$removed=0
foreach ($file in $files) {try {Remove-Item -LiteralPath $file.FullName -Force -ErrorAction Stop; $removed++} catch {}}
Write-Host "Removed files: $removed of $($files.Count)." -ForegroundColor Green