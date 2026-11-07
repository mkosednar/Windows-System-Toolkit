"""Osnovni pregled računalnika Windows z uporabo samo standardne knjižnice Python.
Ustvari besedilno poročilo v mapi Reports; ne spreminja sistemskih nastavitev.
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
    """Vrne skupni in razpoložljivi RAM v GB v sistemu Windows."""
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
        "WINDOWS SYSTEM TOOLKIT - SISTEMSKI PREGLED",
        f"Datum in čas: {now:%d.%m.%Y %H:%M:%S}",
        "",
        f"Računalnik: {platform.node()}",
        f"Operacijski sistem: {platform.system()} {platform.release()}",
        f"Različica sistema: {platform.version()}",
        f"Arhitektura: {platform.machine()}",
        f"Procesor: {platform.processor() or 'Podatek ni na voljo'}",
        f"Logični procesorji: {os.cpu_count() or 'Podatek ni na voljo'}",
        f"Omrežno ime: {socket.gethostname()}",
    ]

    ram = memory_info_gb() if os.name == "nt" else None
    lines.append("")
    lines.append("POMNILNIK")
    if ram:
        total, available, load = ram
        lines += [
            f"Skupni RAM: {total:.2f} GB",
            f"Razpoložljivi RAM: {available:.2f} GB",
            f"Obremenitev RAM: {load} %",
        ]
    else:
        lines.append("Podatki o RAM-u niso na voljo.")

    lines += ["", "PROSTOR NA DISKIH"]
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
                lines.append(f"{root} Podatkov ni mogoče prebrati.")

    report_dir = Path(__file__).resolve().parents[1] / "Reports"
    report_dir.mkdir(parents=True, exist_ok=True)
    report_file = report_dir / f"Sistemski-pregled_{now:%Y%m%d_%H%M%S}.txt"
    report_file.write_text("\n".join(lines), encoding="utf-8")

    print("\n".join(lines))
    print(f"\nPoročilo je shranjeno: {report_file}")


if __name__ == "__main__":
    main()
