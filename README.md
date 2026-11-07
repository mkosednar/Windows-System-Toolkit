# Windows System Toolkit

A collection of original PowerShell, Batch, and Python tools for diagnosing, maintaining, and managing Windows 10 and Windows 11 systems.

**Project separation:** Linux-specific tools are developed in the separate [Linux System Toolkit](https://github.com/mkosednar/Linux-System-Toolkit) repository. This repository remains focused on Windows.

## Requirements

- Windows 10 or Windows 11
- Windows PowerShell 5.1
- Some features require administrator privileges.
- Scripts inspect the system or perform clearly documented tasks. Review each file before use.

## Project structure

### 01 – System Diagnostics
- `SystemInfo.ps1` – basic Windows system information.
- `HardwareInfo.ps1` – hardware overview.
- `RunningProcesses.ps1` – list of currently running processes.
- `StartupPrograms.ps1` – review of programs configured to run at sign-in.
- `DiskHealth.ps1` – physical disk health and available drive space.
- `InstalledSoftware.ps1` – list of installed applications, versions, and publishers.
- `BatteryHealth.ps1` – generates a laptop battery report.
- `EventLogReport.ps1` – review of critical events and errors in the System event log.

### 02 – System Maintenance
- `CleanTemp.ps1` – previews temporary files; deletion requires an explicit parameter and confirmation.
- `RepairWindows.ps1` – DISM, SFC, and CHKDSK diagnostic and repair procedures; administrator privileges are required.

### 03 – Security
- `DefenderStatus.ps1` – Microsoft Defender status overview.

### 04 – Network
- `NetworkInfo.ps1` – basic network configuration information.

### 05 – Utilities
- `ToolkitMenu.bat` – menu for launching selected toolkit scripts.
- `QuickNetworkCheck.bat` – quick network diagnostics and a local report.

### 06 – Python
- `SystemOverview.py` – basic system overview using the Python standard library.

## Safety recommendations

- Back up important data before using repair tools.
- Review scripts and test them in a non-production environment before use.
- Do not run unfamiliar scripts with administrator privileges.
- Reports in the `Reports` directory may contain information about your computer. This directory is intended for local reports and is not part of the published repository files.
- Some diagnostic results depend on hardware, drivers, and the Windows version.

## Language

Documentation, code comments, and user-facing messages are maintained in English. File names and technical command names are also kept in English for consistency.

## License

No open-source license has been selected for this project yet. Until a license is added, use, modification, and redistribution are not automatically permitted.