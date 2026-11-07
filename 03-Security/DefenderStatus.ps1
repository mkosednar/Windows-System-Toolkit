<#
.SYNOPSIS
    Prikaže osnovno stanje Microsoft Defender Antivirus.
.DESCRIPTION
    Skripta samo bere varnostne nastavitve; ničesar ne spreminja.
#>
try {
    $s = Get-MpComputerStatus -ErrorAction Stop
    [pscustomobject]@{
        AntivirusAktiven=$s.AntivirusEnabled
        ZascitaVRealnemCasu=$s.RealTimeProtectionEnabled
        ZascitaPredVohunskoProgramskoOpremo=$s.AntispywareEnabled
        RazlicicaPodpisov=$s.AntivirusSignatureVersion
        ZadnjaPosodobitevPodpisov=$s.AntivirusSignatureLastUpdated
        ZadnjiHiterPregled=$s.QuickScanEndTime
        ZadnjiCelotenPregled=$s.FullScanEndTime
    } | Format-List
} catch {
    Write-Warning "Stanja Defenderja ni mogoče prebrati: $($_.Exception.Message)"
}
