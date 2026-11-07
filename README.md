# Windows System Toolkit

Zbirka izvirnih skript PowerShell za diagnostiko, vzdrževanje in osnovno upravljanje sistema Windows 10 in Windows 11.

## Zahteve

- Windows 10 ali Windows 11
- Windows PowerShell 5.1
- Nekatere funkcije zahtevajo skrbniške pravice.
- Skripte pregledujejo sistem ali izvajajo jasno označena opravila; pred uporabo preberi opis v posamezni datoteki.

## Struktura projekta

### 01 – System Diagnostics
- `SystemInfo.ps1` – osnovne informacije o sistemu Windows.
- `HardwareInfo.ps1` – pregled strojne opreme.
- `RunningProcesses.ps1` – seznam trenutno delujočih procesov.
- `StartupPrograms.ps1` – pregled programov, ki se zaženejo ob prijavi.
- `DiskHealth.ps1` – stanje fizičnih diskov in prosti prostor na pogonih.
- `InstalledSoftware.ps1` – seznam nameščenih programov z različicami in založniki.
- `BatteryHealth.ps1` – ustvari poročilo o bateriji prenosnika.
- `EventLogReport.ps1` – pregled kritičnih dogodkov in napak v dnevniku System.

### 02 – System Maintenance
- `CleanTemp.ps1` – predogled začasnih datotek; brisanje je izrecno potrjeno z dodatnim parametrom in vnosom.

### 03 – Security
- `DefenderStatus.ps1` – pregled stanja Microsoft Defender.

### 04 – Network
- `NetworkInfo.ps1` – osnovne informacije o omrežnih nastavitvah.

## Orodje za popravilo sistema

- `02-System-Maintenance/RepairWindows.ps1` – meni za DISM CheckHealth, ScanHealth in RestoreHealth, SFC /scannow ter CHKDSK /scan. Zahteva skrbniške pravice in zapisuje dnevnik v mapo `Reports`.

Za zagon odpri PowerShell kot skrbnik, pomakni se v mapo skripte in zaženi:

```powershell
.\RepairWindows.ps1
```

## Varnostna priporočila

- Pred uporabo orodij za popravilo naredi varnostno kopijo pomembnih podatkov.
- Skripte najprej preglej in jih preizkusi v neprodukcijskem okolju.
- Ne zaženi neznanih skript s skrbniškimi pravicami.
- Poročila v mapi `Reports` lahko vsebujejo podatke o tvojem računalniku; mapa je namenjena lokalnim poročilom in ni del objavljenih datotek.
- Rezultati nekaterih diagnostičnih ukazov so odvisni od strojne opreme, gonilnikov in različice sistema Windows.

## Jezik

Komentarji in uporabniški izpisi so praviloma v slovenščini. Imena datotek in tehničnih ukazov ostajajo v angleščini zaradi lažje uporabe in vzdrževanja.

## Licenca

Projekt trenutno nima izbrane odprtokodne licence. Do njene določitve uporaba, spreminjanje in nadaljnja distribucija niso samodejno dovoljena.
