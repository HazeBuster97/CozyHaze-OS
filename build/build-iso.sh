#!/bin/bash
# ==============================================================================
# CozyHaze OS - Master ISO Build Skript
# Erstellt eine bootfähige Hybrid-ISO für Apple MacBook Pro 2011 (MacBookPro8,2)
# ==============================================================================

set -euo pipefail

C_RESET="\033[0m"
C_BOLD="\033[1m"
C_CYAN="\033[36m"
C_GREEN="\033[32m"
C_YELLOW="\033[33m"
C_RED="\033[31m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BUILD_DIR="${PROJECT_ROOT}/build/live-build-workspace"
OUTPUT_DIR="${PROJECT_ROOT}/output"
ISO_NAME="cozyhaze-os-2026.10-macbookpro82-amd64.iso"

echo -e "${C_CYAN}${C_BOLD}===================================================================${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}     CozyHaze OS - Build-Pipeline für Apple MacBook Pro 2011       ${C_RESET}"
echo -e "${C_CYAN}${C_BOLD}===================================================================${C_RESET}\n"

# 1. Root-Rechte prüfen
if [ "$(id -u)" -ne 0 ]; then
    echo -e "${C_RED}[FEHLER] Zum Erstellen der Debian live-build ISO sind Root-Rechte erforderlich.${C_RESET}"
    echo -e "Bitte führen Sie das Skript mit 'sudo' aus: ${C_BOLD}sudo ./build/build-iso.sh${C_RESET}"
    exit 1
fi

# 2. Benötigte Build-Abhängigkeiten prüfen
echo -e "${C_BOLD}--- [1/5] Prüfe Build-Werkzeuge ---${C_RESET}"
MISSING_PKGS=()
for tool in lb debootstrap xorriso mksquashfs grub-mkimage; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        MISSING_PKGS+=("$tool")
    fi
done

if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
    echo -e "${C_YELLOW}[!] Fehlende Werkzeuge erkannt: ${MISSING_PKGS[*]}${C_RESET}"
    echo -e "Installiere benötigte Pakete via APT..."
    apt-get update
    apt-get install -y live-build debootstrap xorriso squashfs-tools grub-pc-bin grub-efi-amd64-bin mtools dosfstools
fi
echo -e "${C_GREEN}✓ Alle Build-Werkzeuge einsatzbereit.${C_RESET}\n"

# 3. Live-Build Struktur vorbereiten
echo -e "${C_BOLD}--- [2/5] Bereite Konfigurationen und Overlays vor ---${C_RESET}"
bash "${SCRIPT_DIR}/prepare-live-build.sh"

mkdir -p "$BUILD_DIR"
mkdir -p "$OUTPUT_DIR"

# Auto-Skripte in den Workspace kopieren
mkdir -p "${BUILD_DIR}/auto"
cp -f "${SCRIPT_DIR}/auto"/* "${BUILD_DIR}/auto/"
chmod +x "${BUILD_DIR}/auto"/*

# Projekt-Konfiguration in den Workspace verlinken/kopieren
rm -rf "${BUILD_DIR}/config"
cp -r "${PROJECT_ROOT}/config" "${BUILD_DIR}/"

cd "$BUILD_DIR"

# 4. live-build ausführen
echo -e "\n${C_BOLD}--- [3/5] Führe 'lb clean' und 'lb config' aus ---${C_RESET}"
lb clean --purge
lb config

echo -e "\n${C_BOLD}--- [4/5] Starte ISO-Kompilierung (lb build) ---${C_RESET}"
echo -e "${C_GRAY}Hinweis: Dieser Vorgang lädt Debian 13 Basispakete herunter und komprimiert das SquashFS.${C_RESET}"

BUILD_START=$(date +%s)
lb build

BUILD_END=$(date +%s)
BUILD_TIME=$((BUILD_END - BUILD_START))

# 5. Ergebnis prüfen und Prüfsummen generieren
echo -e "\n${C_BOLD}--- [5/5] Validiere Ergebnis & Generiere Prüfsummen ---${C_RESET}"
GENERATED_ISO=""
if [ -f "live-image-amd64.hybrid.iso" ]; then
    GENERATED_ISO="live-image-amd64.hybrid.iso"
else
    GENERATED_ISO=$(find . -maxdepth 1 -name "*.iso" -printf '%P\n' 2>/dev/null | head -n 1 || true)
fi

if [ -n "$GENERATED_ISO" ] && [ -f "$GENERATED_ISO" ]; then
    TARGET_ISO_PATH="${OUTPUT_DIR}/${ISO_NAME}"
    mv -f "$GENERATED_ISO" "$TARGET_ISO_PATH"
    
    cd "$OUTPUT_DIR"
    sha256sum "$ISO_NAME" > "${ISO_NAME}.sha256"
    sha512sum "$ISO_NAME" > "${ISO_NAME}.sha512"

    ISO_SIZE=$(du -h "$ISO_NAME" | cut -f1)

    echo -e "${C_GREEN}${C_BOLD}===================================================================${C_RESET}"
    echo -e "${C_GREEN}${C_BOLD}  ERFOLG: CozyHaze OS Hybrid-ISO wurde erfolgreich generiert!      ${C_RESET}"
    echo -e "${C_GREEN}${C_BOLD}===================================================================${C_RESET}"
    echo -e "  Datei      : ${C_CYAN}${TARGET_ISO_PATH}${C_RESET}"
    echo -e "  Dateigröße : ${C_BOLD}${ISO_SIZE}${C_RESET}"
    echo -e "  Build-Dauer: $((BUILD_TIME / 60)) Minuten und $((BUILD_TIME % 60)) Sekunden"
    echo -e "  SHA256     : $(cat "${ISO_NAME}.sha256")"
    echo -e "\nDie ISO ist sofort auf USB-Stick bootfähig für Apple MacBook Pro 2011 (UEFI)."
    exit 0
else
    echo -e "${C_RED}[FEHLER] Es wurde keine ISO-Datei im Workspace erzeugt.${C_RESET}"
    echo -e "Bitte prüfen Sie das Build-Log oben auf APT- oder Paket-Abhängigkeitskonflikte."
    exit 1
fi
