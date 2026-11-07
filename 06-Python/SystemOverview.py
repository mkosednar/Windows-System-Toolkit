"""Basic Windows system overview using only the Python standard library.
Creates a text report in the Reports directory; does not modify system settings.
Združljivo s Python 3.9+.
"""
from datetime import datetime
from pathlib import Path
import os
import platform
import shutil
import socket
import ctypes


def memory_info_gb():
    """Returns total and available Windows RAM in GB."""
    class MEMORYSTATUSEX(ctypes.Structure):
        _fields_ = [
            ("dwLength", ctypes.c_ulong),
            ("dwMemoryLoad", ctypes.c_ulong),
            ("ullTotalPhys", ctypes.c_ulonglong),
            ("ullAvailPhys", ctypes.c_ulonglong),
            ("ullTotalPageFile", ctypes.c_ulonglong),
            ("ullAvailPageFile", ctypes.c_ulonglong),
            ("ullTotalVirtual", ctypes.c_ulonglong),
            ("ullAvailVirtual", ctypes.c_ulonglong),
            ("ullAvailExtendedVirtual", ctypes.c_ulonglong),
        ]

    status = MEMORYSTATUSEX()
    status.dwLength = ctypes.sizeof(status)
    if not ctypes.windll.kernel32.GlobalMemoryStatusEx(ctypes.byref(status)):
        return None
    gb = 1024 ** 3
    return status.ullTotalPhys / gb, status.ullAvailPhys / gb, status.dwMemoryLoad


def main():
    now = datetime.now()
    lines = [
        "WINDOWS SYSTEM TOOLKIT - SYSTEM OVERVIEW",
        f"Date and time: {now:%d.%m.%Y %H:%M:%S}",
        "",
        f"Computer: {platform.node()}",
        f"Operating system: {platform.system()} {platform.release()}",
        f"OS version: {platform.version()}",
        f"Architecture: {platform.machine()}",
        f"Procesor: {platform.processor() or 'Not available'}",
        f"Logical processors: {os.cpu_count() or 'Podatek ni na voljo'}",
        f"Network hostname: {socket.gethostname()}",
    ]

    ram = memory_info_gb() if os.name == "nt" else None
    lines.append("")
    lines.append("MEMORY")
    if ram:
        total, available, load = ram
        lines += [
            f"Total RAM: {total:.2f} GB",
            f"Available RAM: {available:.2f} GB",
            f"RAM usage: {load} %",
        ]
    else:
        lines.append("RAM information is unavailable.")

    lines += ["", "DISK SPACE"]
    for letter in "ABCDEFGHIJKLMNOPQRSTUVWXYZ":
        root = f"{letter}:\\"
        if os.path.exists(root):
            try:
                usage = shutil.disk_usage(root)
                gb = 1024 ** 3
                lines.append(
                    f"{root} Skupaj: {usage.total / gb:.1f} GB | "
                    f"Prosto: {usage.free / gb:.1f} GB"
                )
            except OSError:
                lines.append(f"{root} Unable to read disk information.")

    report_dir = Path(__file__).resolve().parents[1] / "Reports"
    report_dir.mkdir(parents=True, exist_ok=True)
    report_file = report_dir / f"System-Overview_{now:%Y%m%d_%H%M%S}.txt"
    report_file.write_text("\n".join(lines), encoding="utf-8")

    print("\n".join(lines))
    print(f"\nReport saved to: {report_file}")


if __name__ == "__main__":
    main()
