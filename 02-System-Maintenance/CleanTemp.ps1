<#
.SYNOPSIS
    Previews temporary files and removes them only after explicit confirmation.
.DESCRIPTION
    Preview mode is the default. Use -Apply to enable deletion.
    Files that cannot be removed are reported; failures are never silently ignored.
#>
[CmdletBinding()]
param([switch]$Apply)

$ErrorActionPreference = 'Stop'
$path = $env:TEMP

if ([string]::IsNullOrWhiteSpace($path) -or -not (Test-Path -LiteralPath $path -PathType Container)) {
    Write-Warning "Temporary directory does not exist or is unavailable: $path"
    return
}

try {
    $files = @(Get-ChildItem -LiteralPath $path -Force -Recurse -File -ErrorAction Stop)
} catch {
    Write-Error "Could not enumerate temporary files: $($_.Exception.Message)"
    exit 1
}

$bytes = ($files | Measure-Object -Property Length -Sum).Sum
if ($null -eq $bytes) { $bytes = 0 }

Write-Host "Directory: $path"
Write-Host "Files: $($files.Count); size: $([math]::Round($bytes / 1MB, 2)) MB"

if (-not $Apply) {
    Write-Host 'Preview only: no files were deleted. Add -Apply to proceed.' -ForegroundColor Yellow
    return
}

if ((Read-Host 'Type YES to confirm') -cne 'YES') {
    Write-Host 'Deletion cancelled. No files were deleted.'
    return
}

$removed = 0
$failed = 0
foreach ($file in $files) {
    try {
        Remove-Item -LiteralPath $file.FullName -Force -ErrorAction Stop
        $removed++
    } catch {
        $failed++
        Write-Warning "Could not remove '$($file.FullName)': $($_.Exception.Message)"
    }
}

Write-Host "Cleanup finished. Removed: $removed; failed: $failed; total discovered: $($files.Count)."
if ($failed -gt 0) {
    Write-Warning 'Some files could not be removed. They may be in use or require different permissions.'
    exit 1
}
