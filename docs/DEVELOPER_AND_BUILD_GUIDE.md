# Entwickler- und Build-Handbuch: CozyHaze OS

---

## 1. Architektur der Build-Pipeline

CozyHaze OS basiert auf dem offiziellen Debian `live-build` Framework (`lb`), das eine bit-reproduzierbare Generierung von Live- und Installationsmedien ermöglicht.

### Verzeichnisstruktur im Projekt:
```text
CozyHaze-OS/
├── boot/              # GRUB- und Plymouth-Themes sowie Bootmenü-Konfigurationen
├── build/             # Build-Skripte (build-iso.sh, Dockerfile.builder, auto/)
├── config/            # live-build Zielkonfigurationen (wird via prepare-live-build.sh assembliert)
├── docs/              # Ausführliche Handbücher und technische Dokumentation
├── hardware/          # MacBookPro8,2 Modprobe-, GRUB-, X11- und Systemd-Treiber
├── installer/         # Calamares Konfigurationsdateien, Module und Branding
├── output/            # Zielverzeichnis für erzeugte Hybrid-ISOs und SHA-Prüfsummen
├── packages/          # Kategorisierte Paketlisten (*.list.chroot)
├── scripts/           # Python- und Shell-Systemwerkzeuge (Control Center, GPU Diag/Repair)
├── tests/             # Automatisierte Test- und QS-Suite (run_all_tests.py, QEMU Runner)
└── themes/            # Wallpaper, Icons, GTK3 Stylesheet und Xfce Desktop-Profile
```

---

## 2. Erstellen der ISO-Datei

### Methode A: Native Build-Umgebung (Debian 13 / Ubuntu Host oder VM)
1. Installieren Sie die Build-Voraussetzungen:
   ```bash
   sudo ./build/setup-build-env.sh
   ```
2. Starten Sie den ISO-Erstellungsprozess:
   ```bash
   sudo ./build/build-iso.sh
   ```
3. Das Skript erzeugt:
   - `output/cozyhaze-os-2026.10-macbookpro82-amd64.iso`
   - `output/cozyhaze-os-2026.10-macbookpro82-amd64.iso.sha256`
   - `output/cozyhaze-os-2026.10-macbookpro82-amd64.iso.sha512`

### Methode B: Containerisierter Build via Docker
Falls Sie auf einem Windows-Host mit Docker Desktop oder einem beliebigen Linux-Server ohne `live-build` arbeiten:
```bash
# 1. Build-Container erstellen
docker build -t cozyhaze-builder -f build/Dockerfile.builder .

# 2. ISO-Build im Container ausführen
docker run --privileged -v $(pwd):/workspace cozyhaze-builder
```

---

## 3. Ausführen der Test- und Qualitätssicherungs-Suite

Vor jedem Release oder Commit führt die Test-Suite umfassende Prüfungen durch:
```bash
python3 tests/run_all_tests.py
```
**Geprüfte Kategorien**:
- **ShellCheck**: Statische Fehlerprüfung für alle Shell- und Bash-Skripte.
- **Python Syntax**: Bytecode-Kompilierung für das Kontrollzentrum und alle Hilfsskripte.
- **Paketlisten**: Validierung von 216 definierten Paketen gegen Debian 13 Konventionen.
- **Hardware-Konfigurationen**: Integritätsprüfung der GMUX-Registerbefehle, Modul-Blacklists und i915-Parameter.
- **Installer & Desktop**: Syntaktische Prüfung von Calamares YAML-Dateien und Desktop-Startern.
- **Branding-Assets**: Überprüfung der Auflösungen und Dateigrößen aller Grafiken.

---

## 4. Testen in QEMU mit UEFI (OVMF)

Testen Sie die erzeugte ISO ohne echtes MacBook in einer virtuellen Umgebung:
```bash
# Unter Linux / WSL
./tests/test-iso-qemu.sh

# Unter Windows (PowerShell)
.\tests\test-iso-qemu.ps1
```
