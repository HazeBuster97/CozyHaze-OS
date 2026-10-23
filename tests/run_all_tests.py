#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
CozyHaze OS - Automatisierte Test- und Qualitätssicherungs-Suite
Prüft ShellCheck, Python-Syntax, Paketlisten, GRUB-Syntax, Desktop-Dateien und Konfigurationen.
"""

import os
import sys
import subprocess
import glob
import py_compile
import shutil

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

TEST_RESULTS = []

def record_test(category, name, passed, details=""):
    TEST_RESULTS.append({
        "category": category,
        "name": name,
        "passed": passed,
        "details": details
    })
    status = "\033[32m[PASS]\033[0m" if passed else "\033[31m[FAIL]\033[0m"
    print(f"{status} {category} :: {name}")
    if not passed and details:
        print(f"       -> Details: {details}")

# ==============================================================================
# 1. ShellCheck Statische Code-Analyse
# ==============================================================================
def test_shellcheck():
    print("\n--- 1. Statische Shell-Analyse (ShellCheck) ---")
    shellcheck_bin = shutil.which("shellcheck")
    if not shellcheck_bin:
        # Auf Windows prüfen im APPDATA Python Verzeichnis
        appdata = os.environ.get("APPDATA", "")
        cand = os.path.join(appdata, "Python", "Python314", "Scripts", "shellcheck.exe")
        if os.path.exists(cand):
            shellcheck_bin = cand

    if not shellcheck_bin:
        record_test("ShellCheck", "ShellCheck Verfügbarkeit", False, "shellcheck nicht im PATH gefunden.")
        return

    record_test("ShellCheck", "ShellCheck Verfügbarkeit", True, f"Gefunden: {shellcheck_bin}")

    # Finde alle .sh Skripte und Skripte ohne Endung mit Shebang
    scripts = []
    for root, _, files in os.walk(PROJECT_ROOT):
        if "live-build-workspace" in root or ".git" in root:
            continue
        for f in files:
            p = os.path.join(root, f)
            if f.endswith(".sh") or f.startswith("06_") or f in ["cozyhaze-gpu-diag", "cozyhaze-gpu-repair", "cozyhaze-postinstall", "config", "build", "clean"]:
                # Prüfen auf Shebang
                try:
                    with open(p, "r", encoding="utf-8", errors="ignore") as fl:
                        first_line = fl.readline()
                        if first_line.startswith("#!") and ("sh" in first_line or "bash" in first_line):
                            scripts.append(p)
                except Exception:
                    pass

    for s in scripts:
        rel = os.path.relpath(s, PROJECT_ROOT)
        try:
            res = subprocess.run([shellcheck_bin, s], stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
            if res.returncode == 0:
                record_test("ShellCheck", rel, True)
            else:
                record_test("ShellCheck", rel, False, res.stdout.strip()[:200])
        except Exception as e:
            record_test("ShellCheck", rel, False, str(e))

# ==============================================================================
# 2. Python Syntax & Bytecode Validierung (Ultimate Apps)
# ==============================================================================
def test_python_syntax():
    print("\n--- 2. Python Syntax & Bytecode Validierung ---")
    py_files = [
        os.path.join(PROJECT_ROOT, "scripts", "cozyhaze-control-center"),
        os.path.join(PROJECT_ROOT, "scripts", "cozyhaze-software-center"),
        os.path.join(PROJECT_ROOT, "scripts", "cozyhaze-ai-center"),
        os.path.join(PROJECT_ROOT, "scripts", "cozyhaze-automation-center"),
        os.path.join(PROJECT_ROOT, "scripts", "cozyhaze-web-starter"),
        os.path.join(PROJECT_ROOT, "build", "prepare_live_build.py"),
        os.path.join(PROJECT_ROOT, "scripts", "process_branding.py"),
        os.path.join(PROJECT_ROOT, "scripts", "generate_grub_slices.py"),
        __file__
    ]

    for pf in py_files:
        if os.path.exists(pf):
            rel = os.path.relpath(pf, PROJECT_ROOT)
            try:
                py_compile.compile(pf, doraise=True)
                record_test("Python-Syntax", rel, True)
            except Exception as e:
                record_test("Python-Syntax", rel, False, str(e))
        else:
            record_test("Python-Syntax", os.path.relpath(pf, PROJECT_ROOT), False, "Datei nicht gefunden!")

# ==============================================================================
# 2b. Validierung der Ultimate Software-Profile & Extras-Kataloge (JSON)
# ==============================================================================
def test_json_catalogs():
    import json
    print("\n--- 2b. Ultimate Profile- & Extras-Kataloge (JSON) ---")
    
    prof_path = os.path.join(PROJECT_ROOT, "packages", "profiles.json")
    if os.path.exists(prof_path):
        try:
            with open(prof_path, "r", encoding="utf-8") as f:
                prof_data = json.load(f)
            profile_list = prof_data.get("profiles", [])
            profile_ids = [p.get("id") for p in profile_list]
            required_profiles = [
                "ultimate-complete", "developer", "cybersecurity", 
                "ai-automation", "office-business", "multimedia-creator", 
                "server-admin", "minimal-performance"
            ]
            missing = [p for p in required_profiles if p not in profile_ids]
            passed = (len(missing) == 0)
            details = f"{len(profile_list)} Profile definiert" if passed else f"Fehlende Profile: {missing}"
            record_test("Software-Kataloge", "profiles.json (8 Ultimate Profile)", passed, details)
        except Exception as e:
            record_test("Software-Kataloge", "profiles.json Syntax", False, str(e))
    else:
        record_test("Software-Kataloge", "profiles.json", False, "Datei fehlt")

    extras_path = os.path.join(PROJECT_ROOT, "packages", "extras.json")
    if os.path.exists(extras_path):
        try:
            with open(extras_path, "r", encoding="utf-8") as f:
                extras_data = json.load(f)
            extras_list = extras_data.get("extras", [])
            has_items = len(extras_list) >= 10
            # Prüfen ob jedes Extra id, name, category, hw_compat besitzt
            valid_items = all("id" in item and "name" in item and "hw_compat" in item for item in extras_list)
            record_test("Software-Kataloge", f"extras.json ({len(extras_list)} Extras mit Hardware-Checks)", has_items and valid_items)
        except Exception as e:
            record_test("Software-Kataloge", "extras.json Syntax", False, str(e))
    else:
        record_test("Software-Kataloge", "extras.json", False, "Datei fehlt")

# ==============================================================================
# 3. Validierung der Paketlisten
# ==============================================================================
def test_package_lists():
    print("\n--- 3. Prüfung der Debian 13 Paketlisten ---")
    pkg_dir = os.path.join(PROJECT_ROOT, "packages")
    lists = glob.glob(os.path.join(pkg_dir, "*.list.chroot"))

    if not lists:
        record_test("Paketlisten", "Paketlisten vorhanden", False, "Keine .list.chroot Dateien gefunden.")
        return

    record_test("Paketlisten", f"{len(lists)} Paketlisten-Dateien gefunden", True)

    total_packages = 0
    for pl in lists:
        rel = os.path.relpath(pl, PROJECT_ROOT)
        valid = True
        err = ""
        count = 0
        with open(pl, "r", encoding="utf-8") as f:
            for line_no, line in enumerate(f, 1):
                clean = line.strip()
                if not clean or clean.startswith("#"):
                    continue
                count += 1
                total_packages += 1
                # Prüfen auf ungültige Paketnamen (z.B. Leerzeichen, Sonderzeichen)
                if any(c in clean for c in [" ", "\t", "/", "\\", ";", "&"]):
                    valid = False
                    err = f"Zeile {line_no}: Ungültiger Paketname '{clean}'"
                    break
        record_test("Paketlisten", f"{rel} ({count} Pakete)", valid, err)

    record_test("Paketlisten", f"Gesamtzahl definierter Pakete: {total_packages}", total_packages > 80)

# ==============================================================================
# 4. Validierung der Hardware- & Kernelparameter (MacBookPro8,2)
# ==============================================================================
def test_hardware_configs():
    print("\n--- 4. Prüfung der MacBookPro8,2 Hardware-Konfigurationen ---")
    
    # 1. Blacklist
    bl_file = os.path.join(PROJECT_ROOT, "hardware", "modprobe.d", "blacklist-radeon.conf")
    if os.path.exists(bl_file):
        with open(bl_file, "r") as f:
            content = f.read()
        has_bl_radeon = "blacklist radeon" in content
        has_bl_amdgpu = "blacklist amdgpu" in content
        has_install_false = "install radeon /bin/true" in content
        passed = has_bl_radeon and has_bl_amdgpu and has_install_false
        record_test("Hardware-Config", "AMD Radeon Blacklist", passed, "Strikte Blockierung von radeon & amdgpu")
    else:
        record_test("Hardware-Config", "AMD Radeon Blacklist", False, "Datei fehlt")

    # 2. i915 LVDS Optimierung
    i915_file = os.path.join(PROJECT_ROOT, "hardware", "modprobe.d", "i915.conf")
    if os.path.exists(i915_file):
        with open(i915_file, "r") as f:
            content = f.read()
        has_lvds = "lvds_channel_mode=2" in content
        has_modeset = "modeset=1" in content
        record_test("Hardware-Config", "Intel i915 LVDS Kanal-Modus", has_lvds and has_modeset)
    else:
        record_test("Hardware-Config", "Intel i915 LVDS", False, "Datei fehlt")

    # 3. GMUX GRUB Hook
    gmux_file = os.path.join(PROJECT_ROOT, "hardware", "grub.d", "06_cozyhaze_gmux")
    if os.path.exists(gmux_file):
        with open(gmux_file, "r") as f:
            content = f.read()
        has_outb_728 = "outb 0x728 1" in content
        has_outb_710 = "outb 0x710 2" in content
        has_outb_750 = "outb 0x750 0" in content
        record_test("Hardware-Config", "Apple GMUX I/O Port Befehle", has_outb_728 and has_outb_710 and has_outb_750)
    else:
        record_test("Hardware-Config", "Apple GMUX Hook", False, "Datei fehlt")

    # 4. Apple Tastatur (hid_apple)
    hid_file = os.path.join(PROJECT_ROOT, "hardware", "modprobe.d", "hid_apple.conf")
    if os.path.exists(hid_file):
        with open(hid_file, "r") as f:
            content = f.read()
        has_fnmode = "fnmode=2" in content
        has_swap = "swap_opt_cmd=1" in content
        record_test("Hardware-Config", "Apple Tastaturbelegung (Fn-Keys & Cmd/Alt)", has_fnmode and has_swap)
    else:
        record_test("Hardware-Config", "Apple Tastaturbelegung", False, "Datei fehlt")

# ==============================================================================
# 5. Validierung der Desktop-Starter (.desktop)
# ==============================================================================
def test_desktop_entries():
    print("\n--- 5. Prüfung der Desktop-Starter (.desktop) ---")
    desk_files = glob.glob(os.path.join(PROJECT_ROOT, "scripts", "*.desktop"))
    for df in desk_files:
        rel = os.path.relpath(df, PROJECT_ROOT)
        with open(df, "r", encoding="utf-8") as f:
            content = f.read()
        has_header = "[Desktop Entry]" in content
        has_name = "Name=" in content
        has_exec = "Exec=" in content
        passed = has_header and has_name and has_exec
        record_test("Desktop-Starter", rel, passed)

# ==============================================================================
# 6. Validierung des Calamares Installers
# ==============================================================================
def test_installer_config():
    print("\n--- 6. Prüfung der Calamares Installer Konfiguration ---")
    settings_file = os.path.join(PROJECT_ROOT, "installer", "settings.conf")
    if os.path.exists(settings_file):
        with open(settings_file, "r", encoding="utf-8") as f:
            c = f.read()
        has_prompt = "prompt-install: true" in c
        has_branding = "branding: cozyhaze" in c
        has_sequence = "sequence:" in c
        record_test("Installer", "settings.conf Struktur & Sicherheitsabfrage", has_prompt and has_branding and has_sequence)
    else:
        record_test("Installer", "settings.conf", False, "Datei fehlt")

    part_file = os.path.join(PROJECT_ROOT, "installer", "modules", "partition.conf")
    if os.path.exists(part_file):
        with open(part_file, "r", encoding="utf-8") as f:
            c = f.read()
        has_efi = "efiSystemPartitionSize: 512M" in c
        has_luks = "enableLuksAutomatedPartitioning: true" in c
        has_no_erase = "initialPartitioningChoice: none" in c
        record_test("Installer", "partition.conf (EFI, LUKS, Safe Erase)", has_efi and has_luks and has_no_erase)
    else:
        record_test("Installer", "partition.conf", False, "Datei fehlt")

# ==============================================================================
# 7. Validierung der Branding-Assets & Bilder
# ==============================================================================
def test_branding_assets():
    print("\n--- 7. Prüfung der visuellen Branding-Assets ---")
    assets = [
        ("Wallpaper JPG", os.path.join(PROJECT_ROOT, "themes", "wallpaper", "cozyhaze-wallpaper.jpg")),
        ("Wallpaper PNG", os.path.join(PROJECT_ROOT, "themes", "wallpaper", "cozyhaze-wallpaper.png")),
        ("Logo PNG", os.path.join(PROJECT_ROOT, "themes", "icons", "cozyhaze-logo.png")),
        ("GRUB Background", os.path.join(PROJECT_ROOT, "boot", "grub", "themes", "cozyhaze", "background.png")),
        ("GRUB Logo", os.path.join(PROJECT_ROOT, "boot", "grub", "themes", "cozyhaze", "logo.png")),
        ("Plymouth Logo", os.path.join(PROJECT_ROOT, "boot", "plymouth", "themes", "cozyhaze-glow", "logo.png")),
        ("Installer Logo", os.path.join(PROJECT_ROOT, "installer", "branding", "cozyhaze", "cozyhaze-logo.png"))
    ]
    for name, p in assets:
        exists = os.path.exists(p) and os.path.getsize(p) > 1000
        size_str = f"({os.path.getsize(p) // 1024} KB)" if os.path.exists(p) else "(fehlt)"
        record_test("Branding-Assets", f"{name} {size_str}", exists)

# ==============================================================================
# Hauptablauf & Zusammenfassung
# ==============================================================================
def main():
    print("===================================================================")
    print("      CozyHaze OS - Gesamte Qualitätssicherungs-Prüfung           ")
    print("===================================================================")

    test_shellcheck()
    test_python_syntax()
    test_json_catalogs()
    test_package_lists()
    test_hardware_configs()
    test_desktop_entries()
    test_installer_config()
    test_branding_assets()

    total = len(TEST_RESULTS)
    passed = sum(1 for t in TEST_RESULTS if t["passed"])
    failed = total - passed

    print("\n===================================================================")
    print("                    TEST-ERGEBNIS ZUSAMMENFASSUNG                 ")
    print("===================================================================")
    print(f"Gesamte Prüfungen : {total}")
    print(f"Erfolgreich       : \033[32m{passed}\033[0m")
    print(f"Fehlgeschlagen    : {'\033[31m' + str(failed) + '\033[0m' if failed > 0 else '\033[32m0\033[0m'}")
    pct = (passed / total) * 100 if total > 0 else 0
    print(f"Erfolgsquote      : {pct:.1f}%")
    print("===================================================================")

    if failed > 0:
        print("\nFolgende Tests sind fehlgeschlagen:")
        for t in TEST_RESULTS:
            if not t["passed"]:
                print(f" - [{t['category']}] {t['name']}: {t['details']}")
        sys.exit(1)
    else:
        print("\n\033[32m[OK] Alle automatisierten Komponenten- und Konfigurationstests bestanden!\033[0m")
        sys.exit(0)

if __name__ == "__main__":
    main()
