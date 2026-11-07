<#
.SYNOPSIS
    Displays the basic status of Microsoft Defender Antivirus.
.DESCRIPTION
    Reads security settings only; makes no changes.
#>
try {
    $s = Get-MpComputerStatus -ErrorAction Stop
    [pscustomobject]@{
        AntivirusEnabled=$s.AntivirusEnabled
        RealTimeProtection=$s.RealTimeProtectionEnabled
        AntispywareEnabled=$s.AntispywareEnabled
        SignatureVersion=$s.AntivirusSignatureVersion
        SignatureLastUpdated=$s.AntivirusSignatureLastUpdated
        LastQuickScan=$s.QuickScanEndTime
        LastFullScan=$s.FullScanEndTime
    } | Format-List
} catch {
    Write-Warning "Could not read Defender status: $($_.Exception.Message)"
}